# frozen_string_literal: true

module Root
  # This is what I want to be able to get subbed in from the Rails Side
  class MockGameUpdater
    attr_accessor :game, :root_game

    def initial_deck_update(_decks); end

    def initial_faction_update(_faction); end

    def full_game_update; end
  end
end
