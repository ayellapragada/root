# frozen_string_literal: true

require_relative '../../pieces/meeple'

module Root
  module Factions
    module Racoons
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
          tinker: %i[boots torch hammer satchel],
          ranger: %i[boots torch crossbow sword]
        }.freeze

        def self.generate_character_list
          POWERS.keys.map do |name|
            new(name: name)
          end
        end

        def initialize(name:)
          super(faction: :racoon)
          @name = name
        end

        def starting_items
          STARTING_ITEMS[name]
        end

        # :nocov:
        def inspect
          "#{name.capitalize}: Power: #{POWERS[name]} | Starting Items: #{starting_items.join(', ')}"
        end
        # :nocov:
      end
    end
  end
end
