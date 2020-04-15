# frozen_string_literal: true

module Root
  module Factions
    module Racoons
      # This will just make it easier to handle relationships
      class Relationships
        attr_reader :relationships

        def initialize(players)
          @relationships = {}
          players.each { |p| relationships[p.faction_symbol] = :neutral }
        end

        def all_neutral?
          relationships.values.all? do |relationship|
            relationship == :neutral
          end
        end

        def count
          @relationships.keys.count
        end
      end
    end
  end
end
