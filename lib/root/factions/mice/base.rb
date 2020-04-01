# frozen_string_literal: true

module Root
  module Factions
    module Mice
      # Bases for cats, they get 3 bases and this handles their operations
      class Base < Pieces::Building
        include Miceable

        attr_reader :base_type

        def initialize(base_type)
          @base_type = base_type
        end
      end
    end
  end
end
