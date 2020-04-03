# frozen_string_literal: true

require_relative './base'

module Root
  module Pieces
    # Handles base logic for the circle pieces.
    class Token < Base
      def piece_type
        :token
      end
    end
  end
end
