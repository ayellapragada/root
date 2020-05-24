# frozen_string_literal: true

require_relative '../pieces/building'
require_relative '../factions/racoons/racoonable'

module Root
  module Grid
    # Node data structure for ruins
    class Ruin < Pieces::Building
      include Factions::Racoons::Racoonable

      def attackable?
        false
      end
    end
  end
end
