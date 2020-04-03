# frozen_string_literal: true

require_relative './base'

module Root
  module Pieces
    # Handles base logic for the square pieces.
    class Building < Base
      def piece_type
        :building
      end
    end
  end
end
