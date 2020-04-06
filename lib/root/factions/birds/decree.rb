# frozen_string_literal: true

module Root
  module Factions
    module Birds
      # Data Structure to contain Decree
      class Decree
        attr_reader :decree

        def initialize
          @decree = { recruit: [], move: [], battle: [], build: [] }
        end

        def choices
          decree.keys
        end

        def [](key)
          decree[key]
        end

        def suits_in(key)
          self[key].map(&:suit)
        end

        def suits_in_decree
          decree.transform_values { |v| v.map(&:suit) }
        end

        def empty?
          decree.values.all?(&:empty?)
        end

        def size
          decree.values.map(&:size).sum
        end
      end
    end
  end
end
