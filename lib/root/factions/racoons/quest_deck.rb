# frozen_string_literal: true

module Root
  module Factions
    module Vagabonds
      # module for catable methods
      # probably just color tbh
      class QuestDeck < Decks::Base
        DECK_SIZE = 15

        # We're not currently interested in getting this list done
        # Really just want to lay the foundation for having quests out
        def generate_deck
          DECK_SIZE.times do
            deck << Factions::Vagabonds::QuestCard.new(
              suit: :fox,
              items: %i[tea coin]
            )
          end
        end
      end
    end
  end
end
