# frozen_string_literal: true

require_relative '../improvement'

module Root
  module Cards
    module Improvements
      class BrutalTactics < Improvement
        def initialize
          super(suit: :bird, name: 'Brutal Tactics', craft: %i[fox fox])
        end

        def type
          :brutal_tactics
        end

        # :nocov:
        def phase
          'Battle'
        end

        def body
          'Atk: May do +1 dmg, Def. gets +1VP'
        end
        # :nocov:
      end
    end
  end
end
