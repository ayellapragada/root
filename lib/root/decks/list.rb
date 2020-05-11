# frozen_string_literal: true

module Root
  module Decks
    # Contains all decks in the game that players can draw from or can access
    # quest and character decks are shared between racoons,
    # but do not go into the discard, so they belong here.
    # decks that interact with discard go into shared
    class List
      attr_reader :shared, :characters, :dominance
      attr_accessor :quests

      def initialize(shared: Decks::Starter.new)
        @shared = shared
        @quests = Factions::Racoons::Quests.new
        @characters = Factions::Racoons::CharacterDeck.new
      end
    end
  end
end
