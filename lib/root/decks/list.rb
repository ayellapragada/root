# frozen_string_literal: true

module Root
  module Decks
    # This is just an easier way to get a list of decks to be passed around
    # We're going to have things like a shared deck
    # But also a racoon list for cases where we have 2 racoons!
    class List
      def self.default_decks_list
        new(
          shared: Decks::Starter.new,
          quest: Factions::Racoons::QuestDeck.new,
          characters: Factions::Racoons::Characters.new
        )
      end

      attr_reader :shared, :quest, :characters

      def initialize(shared:, quest:, characters:)
        @shared = shared
        @quest = quest
        @characters = characters
      end
    end
  end
end
