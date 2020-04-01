# frozen_string_literal: true

module Root
  module Pieces
    # Handles base logic for the square pieces.
    class Base
      def type
        self.class.name.split('::').last.downcase.to_sym
      end

      def display_symbol
        self.class.name.split('::').last[0]
      end

      def attackable?
        true
      end
    end
  end
end
