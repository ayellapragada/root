# frozen_string_literal: true

module Root
  module Factions
    module Racoons
      # All characters can be plopped in here for now
      class CharacterDeck < Decks::Base
        # Only want to lay the foundation for having characters selectable
        def generate_deck
          @deck = Character.generate_character_list
        end
      end
    end
  end
end
