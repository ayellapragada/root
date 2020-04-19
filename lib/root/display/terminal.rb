# frozen_string_literal: true

require 'rainbow'

require_relative './woodlands_map'

module Root
  module Display
    # We currently (and probably will only ever) display to terminal.
    # This handles all of that sort of logic here.
    class Terminal
      # NOT TESTING TERMINAL BECAUSE OOFY
      #:nocov:
      def pick_option(key, options, discard:)
        input = Input.new(key, options, discard: discard)
        input.display_pick_option_message
        input.handle_input
      end

      def render_game(game, current_player, clearings)
        Cursor.hide_cursor
        map = WoodlandsMap.new(game.board, clearings).display
        history = History.new(game.history).display
        other = Info.for_multiple(game.players.except_player(current_player))
        vps = VictoryPoints.new(game.players).display.to_s.split("\n")
        items = ItemsInfo.new(game.board.items).display.to_s.split("\n")
        quests = ActiveQuests.new(game.active_quests).display.to_s.split("\n")
        total_height = map.length + current_player.faction.hand.length

        current_row = Cursor.pos[:row]
        Cursor.move_to_top
        game_info = vps + [' '] + items + [' '] + quests

        render_map(map, game_info, other, history)
        clear_out_rest_of_screen(current_row, total_height)
        render_current_info(current_player)
        render_hand(current_player)
        Cursor.show_cursor
      end

      private

      def render_map(game_map, game_info, others, history)
        buffer = others.map { |str| escape_color(str).length }.max
        game_info_buffer = game_info.map { |str| escape_color(str).length }.max

        merged = game_map.map.with_index do |map_row, idx|
          game_info_line = game_info[idx] || ' '
          other_info = others[idx] || ' '
          hist = history[idx] || '' # Default History / Empty Spaces
          map_row + '  ' +
            append_space(game_info_line, game_info_buffer) + '  ' +
            append_space(other_info, buffer) + '  ' + hist
        end

        merged.each do |row|
          Cursor.clear_line
          Cursor.move_up(2)
          puts row
        end
      end

      def escape_color(str)
        str.gsub(/\e\[([;\d]+)?m/, '')
      end

      def render_current_info(player)
        puts Info.new(player, show_private: true).display
      end

      def append_space(str, num)
        more_spaces = num - str.gsub(/\e\[([;\d]+)?m/, '').length
        str + ' ' * more_spaces
      end

      def render_hand(player)
        hand = player.faction.hand
        puts 'Hand:'
        hand.each do |card|
          puts Rainbow(card.inspect).fg(Colors::SUIT_COLOR[card.suit])
        end
      end

      def clear_out_rest_of_screen(current_row, total_rows)
        Cursor.save_position
        remaining = current_row - total_rows
        remaining.times { Cursor.clear_line }
        Cursor.restore_position
      end
      #:nocov:
    end
  end
end
