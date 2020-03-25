# frozen_string_literal: true

require_relative './base'
require_relative '../factions/cats/catable'

module Root
  module Pieces
    # Handles base logic for Warrior Tokens
    class Meeple < Base
      COLOR_FACTION_MAP = {
        cat: Factions::Cats::Catable::DISPLAY_COLOR
      }.freeze

      attr_reader :faction

      def initialize(faction)
        @faction = faction
      end

      def display_color
        COLOR_FACTION_MAP[faction]
      end

      def display_symbol
        super.downcase
      end
    end
  end
end
