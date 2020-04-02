# frozen_string_literal: true

module Root
  module Factions
    module Mice
      # module for catable methods
      # probably just color tbh
      module Miceable
        DISPLAY_COLOR = :forestgreen

        def faction
          :mice
        end

        def display_color
          DISPLAY_COLOR
        end
      end
    end
  end
end
