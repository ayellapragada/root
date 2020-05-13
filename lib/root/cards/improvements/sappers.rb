# frozen_string_literal: true

require_relative '../improvement'

module Root
  module Cards
    module Improvements
      class Sappers < Improvement
        def initialize
          super(suit: :bird, name: 'Sappers', craft: %i[mouse])
        end

        def type
          :sappers
        end

        # :nocov:
        def phase
          'Battle'
        end

        def body
          'Def: Discard, deal extra hit'
        end
        # :nocov:
      end
    end
  end
end
