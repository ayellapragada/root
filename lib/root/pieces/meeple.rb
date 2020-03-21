# frozen_string_literal: true

module Root
  module Pieces
    # Handles base logic for Warrior Tokens
    class Meeple
      attr_reader :type

      def initialize(type)
        @type = type
      end
    end
  end
end
