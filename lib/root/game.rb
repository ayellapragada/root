# frozen_string_literal: true

module Root
  # Handles logic for starting and handling a game
  class Game
    def self.default_game(with_computers: false, with_humans: false)
      new(
        players: Players::List.default_player_list(with_computers, with_humans),
        board: Boards::Base.new,
        decks: Decks::List.new(shared: Decks::Starter.new)
      )
    end

    # :nocov:
    def self.with_faction_for_play(faction)
      new(
        players: Players::List.for_faction_for_play(faction),
        board: Boards::Base.new,
        decks: Decks::List.new(shared: Decks::Starter.new)
      )
    end

    def self.start_and_play_game(faction:)
      game = with_faction_for_play(faction)
      game.print_display = true
      game.setup
      game.run_game
    end
    # :nocov:

    attr_accessor :players, :board, :decks, :print_display, :history

    def initialize(players:, board:, decks:)
      @players = players
      @board = board
      @decks = decks
      @players.each { |p| p.game = self }
      @print_display = false
      @history = []
    end

    def setup
      setup_by_priority
    end

    def deck
      decks.shared
    end

    def dominance
      decks.shared.dominance
    end

    def active_quests
      decks.quests.active_quests
    end

    def setup_by_priority
      players.order_by_setup_priority.each do |player|
        3.times { player.draw_card }
        player.setup
      end
    end

    # :nocov:
    def run_game
      loop { one_round }
    rescue Errors::WinConditionReached => e
      e.winner.player.add_to_history(
        :f_game_over,
        winner: e.winner.faction_symbol,
        type: e.type
      )

      handle_coalition_victory(e.winner)
      render
    end

    def handle_coalition_victory(winner)
      return unless coalition_winner(winner)

      coalition_winner.add_to_history(
        :f_game_over,
        winner: coalition_winner.faction.faction_symbol,
        type: :coalition
      )
    end

    def coalition_winner(winner)
      fac_sym = winner.fac_sym
      players
        .dominance_holders
        .find { |fac| fac.victory_points == fac_sym }
    end
    # :nocov:

    def one_round
      players.each { |player| take_turn(player) }
    end

    def take_turn(player)
      player.take_turn
    end

    # Simple way to check game state
    def state
      players.map(&:inspect).join("\n")
    end

    def render(clearings: [])
      return unless print_display

      players.each { |player| player.render_game(self, clearings: clearings) }
      nil
    end
  end
end
