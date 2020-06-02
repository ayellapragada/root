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
      attr_reader :faction

      def initialize(faction)
        @faction = faction
      end

      def meeple_of_type?(faction_symbol)
        faction_symbol == faction
      end

      def points_for_removing?
        false
      end

      def piece_type
        :meeple
      end

      def updater_type
        faction
      end
    end
  end
end
