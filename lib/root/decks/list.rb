# frozen_string_literal: true

module Root
  module Decks
    # Contains all decks in the game that players can draw from, our look at
    # Discard and Lost Souls will also get their own deck in the future
    class List
      attr_reader :shared, :characters
      attr_accessor :quests

      def initialize(shared: Decks::Starter.new)
        @shared = shared
        @quests = Factions::Racoons::Quests.new
        @characters = Factions::Racoons::CharacterDeck.new
      end
    end
  end
end
