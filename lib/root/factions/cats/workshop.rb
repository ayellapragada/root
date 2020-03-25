# frozen_string_literal: true

require_relative '../../pieces/building'
require_relative './catable'

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
