# frozen_string_literal: true

module Root
  module Factions
    module Birds
      # module for catable methods
      # probably just color tbh
      module Birdable
        DISPLAY_COLOR = :dodgerblue

        def faction
          :bird
        end

        def display_color
          DISPLAY_COLOR
        end
      end
    end
  end
end
