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
      def pick_option(key, options, discard:, info:)
        input = Input.new(key, options, discard: discard, info: info)
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
        dominance = Dominance.new([]).display.to_s.split("\n")
        quests = ActiveQuests.new(game.active_quests).display.to_s.split("\n")

        Cursor.move_to_top
        game_info = vps + items + dominance + quests

        render_map(map, game_info, other, history)
        render_current_info(current_player)
        render_hand(current_player)
        clear_out_rest_of_screen
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
          print_and_clear_row(row)
        end
      end

      def escape_color(str)
        str.gsub(/\e\[([;\d]+)?m/, '')
      end

      def render_current_info(player)
        Info.new(player, show_private: true).display.split("\n").each do |line|
          print_and_clear_row(line)
        end
      end

      def append_space(str, num)
        more_spaces = num - str.gsub(/\e\[([;\d]+)?m/, '').length
        str + ' ' * more_spaces
      end

      def render_hand(player)
        hand = player.faction.hand
        hand.each do |card|
          str = Rainbow(card.inspect).fg(Colors::SUIT_COLOR[card.suit])
          print_and_clear_row(str)
        end
      end

      def print_and_clear_row(str)
        puts "#{str}\e[0K"
      end

      def clear_out_rest_of_screen
        Cursor.move_up(1)
        puts "\e[0J"
        Cursor.move_up(2)
      end
      #:nocov:
    end
  end
end
