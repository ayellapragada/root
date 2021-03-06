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
            Root::Players::Computer.for('Ultron', :racoon)
          )
        end
      end

      # :nocov:
      def self.for_faction_for_play(faction)
        cpus = %i[cats birds mice racoon] - [faction]
        comps = cpus.map { |fac| Root::Players::Computer.for(fac.to_s, fac) }
        new(Root::Players::Human.for('Hal', faction), *comps)
      end

      def self.human_list
        new(
          Root::Players::Human.for('Hal', :cats),
          Root::Players::Human.for('Brainiac', :mice),
          Root::Players::Human.for('Tron', :birds),
          Root::Players::Human.for('Ultron', :racoon)
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

      def victory_points
        players.map do |player|
          {
            faction: player.faction.faction_symbol,
            victory_points: player.faction.victory_points,
            color: player.faction.display_color
          }
        end
      end

      def options_to_coalition_with(fac)
        choices =
          except_player(fetch_player(fac))
          .map(&:faction)
          .reject(&:win_via_dominance?)

        min_vp = choices.map(&:victory_points).min

        choices
          .select { |faction| faction.victory_points == min_vp }
          .map(&:faction_symbol)
      end

      def dominance_holders
        players
          .map(&:faction)
          .select(&:win_via_dominance?)
          .map(&:faction_symbol)
      end

      private

      attr_accessor :current_player_index
    end
  end
end
