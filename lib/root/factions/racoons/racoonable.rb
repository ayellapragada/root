# frozen_string_literal: true

module Root
  module Factions
    module Racoons
      # module for catable methods
      # probably just color tbh
      module Racoonable
        DISPLAY_COLOR = :webgray

        def faction
          :racoon
        end

        def display_color
          DISPLAY_COLOR
        end
      end
    end
  end
end
