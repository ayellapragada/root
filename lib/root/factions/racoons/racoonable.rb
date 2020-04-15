# frozen_string_literal: true

module Root
  module Factions
    module Vagabonds
      # module for catable methods
      # probably just color tbh
      module Vagabondable
        DISPLAY_COLOR = :webgray

        def faction
          :vagabond
        end

        def display_color
          DISPLAY_COLOR
        end
      end
    end
  end
end
