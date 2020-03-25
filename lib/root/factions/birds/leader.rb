# frozen_string_literal: true

require_relative '../../cards/base'

module Root
  module Factions
    module Birds
      # Recruiter building for cats, how they get more warriors out.
      class Leader < Cards::Base
        def self.generate_initial
          [
            new(suit: :bird, leader: :builder, decree: %i[recruit move]),
            new(suit: :bird, leader: :commander, decree: %i[move battle]),
            new(suit: :bird, leader: :charismatic, decree: %i[recruit battle]),
            new(suit: :bird, leader: :despot, decree: %i[move build])
          ]
        end
        include Birdable

        attr_accessor :leader, :decree

        def initialize(suit:, leader:, decree:)
          super(suit: suit)
          @leader = leader
          @decree = decree
        end
      end
    end
  end
end
