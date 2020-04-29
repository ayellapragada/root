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

        DISPLAY = {
          neutral: '0',
          one: '1',
          two: '2',
          allied: 'A',
          hostile: 'H'
        }.freeze

        def formatted_display
          @relationships
            .map { |k, v| "#{k.capitalize}: #{DISPLAY[v]}" }
            .join(' | ')
        end
      end
    end
  end
end
