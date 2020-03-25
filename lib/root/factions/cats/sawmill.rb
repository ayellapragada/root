# frozen_string_literal: true

module Root
  module Factions
    module Cats
      # Sawmill building for cats, how they get wood for buildings.
      class Sawmill < Pieces::Building
        include Catable
      end
    end
  end
end
