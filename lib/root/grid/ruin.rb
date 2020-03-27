# frozen_string_literal: true

require_relative '../pieces/building'
require_relative '../factions/vagabonds/vagabondable'

module Root
  module Grid
    # Node data structure for ruins
    class Ruin < Pieces::Building
      include Factions::Vagabonds::Vagabondable
    end
  end
end
