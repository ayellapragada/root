# frozen_string_literal: true

module Root
  module Players
    # Maintains list of current players and has easy methods to access things
    # like victory points for everyone and etc.
    class List
      include Enumerable

      attr_reader :players

      def self.default_player_list(with_computers = false, with_humans = false)
        # :nocov:
        if with_humans
          human_list
        else
          # :nocov:
          new(
            make_first_player(with_computers),
            Root::Players::Computer.for('Hal', :cats),
            Root::Players::Computer.for('Tron', :birds),
            Root::Players::Computer.for('Ultron', :vagabond)
          )
        end
      end

      # :nocov:
      def self.for_faction_for_play
        new(
          Root::Players::Human.for('Akshith', :cats),
          Root::Players::Computer.for('Hal', :mice),
          Root::Players::Computer.for('Tron', :birds),
          Root::Players::Computer.for('Ultron', :vagabond)
        )
      end

      def self.human_list
        new(
          Root::Players::Human.for('Hal', :cats),
          Root::Players::Human.for('Brainiac', :mice),
          Root::Players::Human.for('Tron', :birds),
          Root::Players::Human.for('Ultron', :vagabond)
        )
      end
      # :nocov:

      # Computers don't need mocked input,
      # so if we do an all computer game life is easier
      def self.make_first_player(with_computers)
        if with_computers
          Root::Players::Computer.for('Sneaky', :mice)
        else
          Root::Players::Human.for('Sneaky', :mice)
        end
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

      def except_player(player)
        players.reject { |other_player| other_player == player }
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
          a.faction.setup_priority <=> b.faction.setup_priority
        end
      end

      private

      attr_accessor :current_player_index
    end
  end
end
