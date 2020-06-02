# frozen_string_literal: true

require_relative '../../../pieces/meeple'

module Root
  module Factions
    module Racoons
      module Characters
        # Base logic for characters, they can handle powers and items
        class Character < Pieces::Meeple
          attr_accessor :f

          def self.for(name)
            CharacterDeck::CHARACTER_MAPPING[name]
          end

          def initialize
            super(faction: :racoon)
          end

          def name
            type.to_s.capitalize
          end

          def torch?
            f.available_items_include?(:torch)
          end
        end
      end
    end
  end
end
