# frozen_string_literal: true

require_relative '../../cards/base'
require_relative './birdable'

module Root
  module Factions
    module Birds
      # Recruiter building for cats, how they get more warriors out.
      class Leader < Cards::Base
        def self.generate_initial
          [
            new(
              leader: :builder,
              decree: %i[recruit move],
              ability: 'Ignore your Disdain for Trade when you craft.'
            ),
            new(
              leader: :commander,
              decree: %i[move battle], ability: 'As attacker in battle you deal an extra hit.'
            ),
            new(
              leader: :charismatic,
              decree: %i[recruit battle],
              ability: 'You place two warriors, not one when you recruit.'
            ),
            new(
              leader: :despot,
              decree: %i[move build],
              ability: 'If you remove at least one enemy building or token in battle, score one point.'
            )
          ]
        end
        include Birdable

        attr_accessor :leader, :decree, :ability

        def initialize(leader:, decree:, ability:)
          super(suit: :bird)
          @leader = leader
          @decree = decree
          @ability = ability
        end

        # :nocov:
        def inspect
          "#{leader.capitalize}: #{ability} (Viziers: #{decree.map(&:capitalize).join(' + ')})"
        end
        # :nocov:
      end
    end
  end
end
