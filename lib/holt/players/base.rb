# frozen_string_literal: true

require_relative '../factions/bird'
require_relative '../factions/cat'
require_relative '../factions/mouse'
require_relative '../factions/vagabond'

FACTION_MAPPING = {
  birds: Holt::Factions::Bird,
  cats: Holt::Factions::Cat,
  mice: Holt::Factions::Mouse,
  vagabond: Holt::Factions::Vagabond
}.freeze

module Holt
  module Players
    # Safe spot for all centralized player logic
    class Base
      def self.for(name, faction)
        new(name: name, faction: FACTION_MAPPING[faction])
      end

      attr_reader :name

      def initialize(name:, faction:)
        @name = name
        @faction = faction
      end
    end
  end
end
