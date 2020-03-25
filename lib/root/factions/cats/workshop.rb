# frozen_string_literal: true

module Root
  module Factions
    module Cats
      # How cats craft!
      class Workshop < Pieces::Building
        include Catable
      end
    end
  end
end
