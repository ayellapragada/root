# frozen_string_literal: true

module Root
  module Factions
    module Mice
      # Bases for cats, they get 3 bases and this handles their operations
      class Base < Pieces::Building
        include Miceable

        attr_reader :suit

        def initialize(suit)
          @suit = suit
        end
      end
    end
  end
end
