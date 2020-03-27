# frozen_string_literal: true

module Root
  module Decks
    # This is just an easier way to get a list of decks to be passed around
    # We're going to have things like a shared deck
    # But also a vagabond list fo cases where we have 2 vagabonds!
    class List
      def self.default_decks_list
        new(
          shared: Decks::Starter.new,
          quest: Factions::Vagabonds::QuestDeck.new
        )
      end

      attr_accessor :shared, :quest

      def initialize(shared:, quest:)
        @shared = shared
        @quest = quest
      end
    end
  end
end
