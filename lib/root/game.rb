# frozen_string_literal: true

module Root
  # Handles logic for starting and handling a game
  class Game
    def self.default_game(with_computers: false, with_humans: false)
      new(
        players: Players::List.default_player_list(with_computers, with_humans),
        board: Boards::Base.new,
        decks: Decks::List.default_decks_list
      )
    end

    # :nocov:
    def self.with_faction_for_play
      new(
        players: Players::List.for_faction_for_play,
        board: Boards::Base.new,
        decks: Decks::List.default_decks_list
      )
    end

    def self.start_and_play_game
      game = with_faction_for_play
      game.print_display = true
      game.setup
      game.run_game
      game.render
    end
    # :nocov:

    attr_accessor :players, :board, :decks, :active_quests, :print_display,
                  :history

    def initialize(players:, board:, decks:)
      @players = players
      @board = board
      @decks = decks
      @active_quests = []
      @players.each { |p| p.game = self }
      @print_display = false
      @history = []
    end

    def deck
      decks.shared
    end

    def quest_deck
      decks.quest
    end

    def setup
      setup_quests
      setup_by_priority
    end

    def setup_by_priority
      players.order_by_setup_priority.each do |player|
        3.times { player.draw_card(deck) }
        player.setup(
          decks: decks,
          players: players
        )
      end
    end

    def run_game
      loop { players.each { |player| take_turn(player) } }
    end

    def take_turn(player)
      player.take_turn(
        players: players,
        active_quests: active_quests
      )
    end

    # Simple way to check game state
    def state
      players.map(&:inspect).join("\n")
    end

    def setup_quests
      @active_quests = quest_deck.draw_from_top(3)
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
