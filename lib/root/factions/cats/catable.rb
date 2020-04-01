# frozen_string_literal: true

module Root
  module Factions
    module Cats
      # module for catable methods
      # probably just color tbh
      module Catable
        DISPLAY_COLOR = :darkorange

        def faction
          :cat
        end

        def display_color
          DISPLAY_COLOR
        end
      end
    end
  end
end
