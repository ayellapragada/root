# frozen_string_literal: true

module Root
  # Handles logic for starting and handling a game
  class Game
    def self.default_game(with_computers: false)
      new(
        players: Players::List.default_player_list(with_computers),
        board: Boards::Woodlands.new,
        decks: Decks::List.default_decks_list
      )
    end

    attr_accessor :players, :board, :decks, :active_quests

    def initialize(players:, board:, decks:)
      @players = players
      @board = board
      @decks = decks
      @active_quests = []
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
          board: board,
          decks: decks,
          players: players
        )
      end
    end

    def run_game
      players.each { |player| take_turn(player) }
    end

    def take_turn(player)
      player.take_turn(
        board: board,
        decks: decks,
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

    def render
      players.each { |player| player.render_game(self) }
    end
  end
end
