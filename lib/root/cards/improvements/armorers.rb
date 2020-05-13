# frozen_string_literal: true

require_relative '../improvement'

module Root
  module Cards
    module Improvements
      class Armorers < Improvement
        def initialize
          super(suit: :bird, name: 'Armorers', craft: %i[fox])
        end

        def type
          :armorers
        end

        # :nocov:
        def phase
          'Battle'
        end

        def body
          'Discard to ignore rolled hits taken'
        end
        # :nocov:
      end
    end
  end
end
