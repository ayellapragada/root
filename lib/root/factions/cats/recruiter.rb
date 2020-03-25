# frozen_string_literal: true

require_relative '../../pieces/building'
require_relative './catable'

module Root
  module Factions
    module Cats
      # Recruiter building for cats, how they get more warriors out.
      class Recruiter < Pieces::Building
        include Catable
      end
    end
  end
end
