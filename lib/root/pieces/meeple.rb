# frozen_string_literal: true

require_relative './base'
require_relative '../factions/cats/catable'
require_relative '../factions/birds/birdable'
require_relative '../factions/mice/miceable'
require_relative '../factions/racoons/racoonable'

module Root
  module Pieces
    # Handles base logic for Warrior Tokens
    class Meeple < Base
      COLOR_FACTION_MAP = {
        cats: Factions::Cats::Catable::DISPLAY_COLOR,
        birds: Factions::Birds::Birdable::DISPLAY_COLOR,
        mice: Factions::Mice::Miceable::DISPLAY_COLOR,
        racoon: Factions::Racoons::Racoonable::DISPLAY_COLOR
      }.freeze

      attr_reader :faction

      def initialize(faction)
        @faction = faction
      end

      def display_color
        COLOR_FACTION_MAP[faction]
      end

      def display_symbol
        'o'
      end

      def meeple_of_type?(faction_symbol)
        faction_symbol == faction
      end
    end
  end
end
