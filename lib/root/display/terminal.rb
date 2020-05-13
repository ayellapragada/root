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
      def pick_option(key, options, game:, info:)
        input = Input.new(key, options, game: game, info: info)
        input.display_pick_option_message
        input.handle_input
      end

      def be_shown_hand(hand)
        res = hand.empty? ? 'No Cards In Hand' : hand.map(&:inspect).join("\n")
        Menu.new(res).display
      end

      def render_game(game, current_player, clearings)
        Cursor.hide_cursor
        map = WoodlandsMap.new(game.board, clearings).display
        history = History.new(game.history).display.to_s.split("\n")
        current = Info.new(current_player, show_private: true).display.split("\n")
        other = Info.for_multiple(game.players.except_player(current_player))
        vps = VictoryPoints.new(game.players).display.to_s.split("\n")
        items = ItemsInfo.new(game.board.items).display.to_s.split("\n")
        dominance = Dominance.new(game.dominance).display.to_s.split("\n")
        quests = ActiveQuests.new(game.active_quests).display.to_s.split("\n")

        Cursor.move_to_top
        game_info = vps + items + dominance + quests

        render_map(map, game_info, other, history)
        render_current_info(current)
        render_hand(current_player)
        clear_out_rest_of_screen
        Cursor.show_cursor
      end

      private

      def render_map(game_map, game_info, others, history)
        merged = game_map.map.with_index do |map_row, idx|
          game_info_line = game_info[idx] || ' '
          other_info = others[idx] || ' '
          hist = history[idx] || '' # Default History / Empty Spaces
          hist + '  ' + map_row + '  ' + game_info_line + '  ' + other_info
        end

        merged.each { |row| print_and_clear_row(row) }
      end

      def render_current_info(current)
        current.each { |line| print_and_clear_row(line) }
      end

      def render_hand(player)
        return if player.faction.hand.empty?

        Hand
          .new(player.faction.hand)
          .display
          .to_s
          .split("\n")
          .each { |line| print_and_clear_row(line) }
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
