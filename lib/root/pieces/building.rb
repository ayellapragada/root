# frozen_string_literal: true

module Root
  module Pieces
    # Handles base logic for the square pieces.
    class Building
      def type
        self.class.name.split('::').last.downcase.to_sym
      end
    end
  end
end
