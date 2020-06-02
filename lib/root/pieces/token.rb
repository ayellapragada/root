# frozen_string_literal: true

require_relative './base'

module Root
  module Pieces
    # Handles base logic for the circle pieces.
    class Token < Base
      def piece_type
        :token
      end

      def points_for_removing?
        true
      end
    end
  end
end
