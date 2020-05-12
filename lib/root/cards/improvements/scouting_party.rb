# frozen_string_literal: true

require_relative '../improvement'

module Root
  module Cards
    module Improvements
      class ScoutingParty < Improvement
        def initialize
          super(suit: :mouse, name: 'Scouting Party', craft: %i[mouse mouse])
        end

        def type
          :scouting_party
        end

        # :nocov:
        def body
          'As attacker, not affected by ambush'
        end
        # :nocov:
      end
    end
  end
end
