# frozen_string_literal: true

require_relative './character'

module Root
  module Factions
    module Racoons
      module Characters
        # Thief Specific Logic
        class Thief < Character
          STARTING_ITEMS = %i[boots torch tea sword].freeze
          POWER = :steal
        end
      end
    end
  end
end
