# frozen_string_literal: true

module Root
  # Handles logic for starting and handling a game
  class Game
    def self.default_game(with_computers: false, with_humans: false)
      new(
        players: Players::List.default_player_list(with_computers, with_humans),
        board: Boards::Base.new,
        deck: Decks::Starter.new
      )
    end

    # :nocov:
    def self.with_faction_for_play(faction)
      new(
        players: Players::List.for_faction_for_play(faction),
        board: Boards::Base.new,
        deck: Decks::Starter.new
      )
    end

    def self.start_and_play_game(faction:)
      game = with_faction_for_play(faction)
      game.print_display = true
      game.setup
      game.run_game
    end
    # :nocov:

    attr_accessor :players, :board, :deck, :quests, :characters,
                  :print_display, :history

    def initialize(players:, board:, deck:)
      @players = players
      @board = board
      @deck = deck
      @quests = Factions::Racoons::Quests.new
      @characters = Factions::Racoons::CharacterDeck.new
      @players.each { |p| p.game = self }
      @print_display = false
      @history = []
    end

    def setup
      setup_by_priority
    end

    def active_quests
      quests.active_quests
    end

    def setup_by_priority
      players.order_by_setup_priority.each do |player|
        3.times { player.draw_card }
        player.setup(
          players: players,
          characters: characters
        )
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
      render
    end
    # :nocov:

    def one_round
      players.each { |player| take_turn(player) }
    end

    def take_turn(player)
      player.take_turn(
        players: players,
        quests: quests
      )
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

    # :nocov:
    def test_render
      Display::Terminal.new.render_game(self, players.fetch_player(:mice))
    end
    # :nocov:
  end
end
