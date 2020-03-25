# frozen_string_literal: true

module Root
  module Factions
    module Birds
      # Recruiter building for cats, how they get more warriors out.
      class Roost < Pieces::Building
        include Birdable
      end
    end
  end
end
