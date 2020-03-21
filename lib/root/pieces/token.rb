# frozen_string_literal: true

module Root
  module Pieces
    # Handles base logic for the circle pieces.
    class Token
      def type
        self.class.name.split('::').last.downcase.to_sym
      end
    end
  end
end
