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

      def self.from_db(record, updater: MockGameUpdater.new)
        cards_list = Root::Decks::Starter.new.deck
        quests_list = Root::Factions::Racoons::QuestDeck.new.deck
        character_list = Root::Factions::Racoons::CharacterDeck.new.deck

        new(
          shared: Decks::Starter.new(
            deck: take_card_from_deck(record[:shared], cards_list),
            discard: take_card_from_deck(record[:discard], cards_list),
            dominance: take_card_from_deck(record[:dominance], cards_list) || [],
            lost_souls: take_card_from_deck(record[:lost_souls], cards_list),
            skip_generate: true
          ),
          quests: Factions::Racoons::Quests.new(
            quests: take_card_from_deck(record[:quests], quests_list),
            active_quests: take_card_from_deck(record[:active_quests], quests_list),
            skip_generate: true
          ),
          characters: Factions::Racoons::CharacterDeck.new(
            deck: take_meeples_from_deck(record[:characters], character_list),
            skip_generate: true
          ),
          updater: updater,
          skip_generate: true
        )
      end

      def self.take_card_from_deck(list_from_db, cards_list)
        return [] unless list_from_db

        list_from_db.map do |db_card|
          cards_list.find do |card|
            card.name == db_card[:name] && card.suit == db_card[:suit].to_sym
          end.tap do |card|
            card.id = db_card[:id]
          end
        end
      end

      def self.take_meeples_from_deck(list_from_db, cards_list)
        return [] unless list_from_db

        list_from_db.map do |db_card|
          cards_list.find do |card|
            card.type == db_card.to_sym
          end
        end
      end

      def initialize(
        shared: Decks::Starter.new,
        quests: Factions::Racoons::Quests.new,
        characters: Factions::Racoons::CharacterDeck.new,
        updater: MockGameUpdater.new,
        skip_generate: false
      )
        @shared = shared
        @quests = quests
        @characters = characters
        updater.initial_deck_update(self) unless skip_generate
      end
    end
  end
end
