# frozen_string_literal: true

module Root
  module Factions
    module Racoons
      # module for catable methods
      # probably just color tbh
      class QuestDeck < Decks::Base
        DECK_SIZE = 15

        # We're not currently interested in getting this list done
        # Really just want to lay the foundation for having quests out
        def generate_deck
          list_of_cards!
          deck.shuffle!
        end

        def list_of_cards!
          [
            # rubocop:disable all
            { suit: :fox, name: 'Fundraising', items: %i[tea coin] },
            { suit: :fox, name: 'Errand', items: %i[tea boots] },
            { suit: :fox, name: 'Logistics Help', items: %i[boots satchel] },
            { suit: :fox, name: 'Repair a Shed', items: %i[torch hammer] },
            { suit: :fox, name: 'Give a Speech', items: %i[torch tea] },

            { suit: :bunny, name: 'Guard Duty', items: %i[torch sword] },
            { suit: :bunny, name: 'Errand', items: %i[tea boots] },
            { suit: :bunny, name: 'Give a Speech', items: %i[torch tea] },
            { suit: :bunny, name: 'Fend Off a Bear', items: %i[torch crossbow] },
            { suit: :bunny, name: 'Expel Bandits', items: %i[sword sword] },

            { suit: :mouse, name: 'Expel Bandits', items: %i[sword sword] },
            { suit: :mouse, name: 'Guard Duty', items: %i[torch sword] },
            { suit: :mouse, name: 'Fend Off a Bear', items: %i[torch crossbow] },
            { suit: :mouse, name: 'Escort', items: %i[boots boots] },
            { suit: :mouse, name: 'Logistics Help', items: %i[boots satchel] },
            # rubocop:enable all
          ].each do |row|
            deck << Factions::Racoons::QuestCard.new(
              suit: row[:suit],
              name: row[:name],
              items: row[:items]
            )
          end
        end
      end
    end
  end
end
