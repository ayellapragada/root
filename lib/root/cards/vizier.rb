# frozen_string_literal: true

require_relative './base'

module Root
  module Cards
    # This is for the birdables
    class Vizier < Base
      def initialize
        super(suit: :bird)
      end

      def vizier?
        true
      end
    end
  end
end
