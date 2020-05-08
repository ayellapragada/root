# frozen_string_literal: true

require_relative './character'

module Root
  module Factions
    module Racoons
      module Characters
        # Ranger Specific Logic
        class Ranger < Character
          STARTING_ITEMS = %i[boots torch crossbow sword].freeze
          POWER = :hideout
        end
      end
    end
  end
end
