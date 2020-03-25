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

        def [](key)
          decree[key]
        end

        def empty?
          decree.values.all?(&:empty?)
        end
      end
    end
  end
end
