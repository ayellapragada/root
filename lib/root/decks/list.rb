# frozen_string_literal: true

module Root
  module Decks
    # Contains all decks in the game that players can draw from or can access
    # quest and character decks are shared between racoons,
    # but do not go into the discard, so they belong here.
    # decks that interact with discard go into shared
    class List
      attr_reader :shared, :characters, :dominance, :updater
      attr_accessor :quests

      def self.from_db(record, updater: MockDecksUpdater.new)
        new(
          shared: Decks::Starter.new(
            deck: record[:shared],
            discard: record[:discard],
            dominance: record[:dominance] || [],
            lost_souls: record[:lost_souls],
            skip_generate: true
          ),
          quests: Factions::Racoons::Quests.new(
            quests: record[:quests],
            active_quests: record[:active_quests],
            skip_generate: true
          ),
          characters: Factions::Racoons::CharacterDeck.new(
            deck: record[:characters],
            skip_generate: true
          ),
          updater: updater,
          skip_generate: true
        )
      end

      def initialize(
        shared: Decks::Starter.new,
        quests: Factions::Racoons::Quests.new,
        characters: Factions::Racoons::CharacterDeck.new,
        updater: MockDecksUpdater.new,
        skip_generate: false
      )
        @shared = shared
        @quests = quests
        @characters = characters
        @updater = updater
        @updater.decks = self
        updater.full_update unless skip_generate
      end
    end
  end
end
