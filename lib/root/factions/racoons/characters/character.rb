# frozen_string_literal: true

require_relative '../../../pieces/meeple'

module Root
  module Factions
    module Racoons
      module Characters
        # Base logic for characters, they can handle powers and items
        class Character < Pieces::Meeple
          def self.for(name)
            CharacterDeck::CHARACTER_MAPPING[name]
          end

          def initialize
            super(faction: :racoon)
          end

          def name
            type.to_s.capitalize
          end

          # :nocov:
          def inspect
            power = self.class::POWER
            starting_items = self.class::STARTING_ITEMS.join(', ')
            "#{name}: Power: #{power} | Start: #{starting_items}"
          end
          # :nocov:
        end
      end
    end
  end
end
