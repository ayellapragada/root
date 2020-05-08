# frozen_string_literal: true

require_relative './character'

module Root
  module Factions
    module Racoons
      module Characters
        # Tinker specific logic
        class Tinker < Character
          STARTING_ITEMS = %i[boots torch hammer satchel].freeze
          POWER = :day_labor
        end
      end
    end
  end
end
