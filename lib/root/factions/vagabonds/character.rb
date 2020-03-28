# frozen_string_literal: true

require_relative '../../pieces/meeple'

module Root
  module Factions
    module Vagabonds
      # All characters can be plopped in here for now
      class Character < Pieces::Meeple
        attr_reader :name

        POWERS = {
          thief: :steal,
          tinker: :day_labor,
          ranger: :hideout
        }.freeze

        STARTING_ITEMS = {
          thief: %i[boots torch tea sword],
          tinker: %i[boots torch bag hammer],
          ranger: %i[boots torch crossbow sword]
        }.freeze

        def self.generate_character_list
          POWERS.keys.map do |name|
            new(name: name)
          end
        end

        def initialize(name:)
          super(faction: :vagabond)
          @name = name
        end
      end
    end
  end
end