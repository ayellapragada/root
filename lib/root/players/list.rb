# frozen_string_literal: true

module Root
  module Players
    # Maintains list of current players and has easy methods to access things
    # like victory points for everyone and etc.
    class List
      include Enumerable

      attr_reader :players

      def self.default_player_list
        new(
          Root::Players::Human.for('Sneaky', :mice),
          Root::Players::Computer.for('Hal', :cats),
          Root::Players::Computer.for('Tron', :birds),
          Root::Players::Computer.for('Ultron', :vagabond)
        )
      end

      def initialize(*players)
        @players = players
        @current_player_index = 0
      end

      def current_player
        players[current_player_index]
      end

      def each
        players.each { |player| yield player }
      end

      def fetch_player(faction_symbol)
        players.find { |player| player.faction_symbol == faction_symbol }
      end

      def player_count
        players.count
      end

      def rotate_current_player
        self.current_player_index += 1
        self.current_player_index = 0 if current_player_index >= players.length
      end

      def order_by_setup_priority
        players.sort do |a, b|
          a&.faction&.setup_priority <=> b&.faction&.setup_priority
        end
      end

      private

      attr_accessor :current_player_index
    end
  end
end
