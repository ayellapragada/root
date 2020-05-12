# frozen_string_literal: true

require_relative '../improvement'

module Root
  module Cards
    module Improvements
      class CommandWarren < Improvement
        def initialize
          super(
            suit: :rabbit,
            name: 'Command Warren',
            craft: %i[rabbit rabbit]
          )
        end

        def type
          :command_warren
        end

        # :nocov:
        def body
          'Start of Daylight: May initiate a battle'
        end
        # :nocov:

        def faction_use(faction)
          faction.battle
        end
      end
    end
  end
end
