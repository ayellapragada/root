# frozen_string_literal: true

require_relative './characters/ranger'
require_relative './characters/thief'
require_relative './characters/tinker'

module Root
  module Factions
    module Racoons
      # All characters can be plopped in here for now
      class CharacterDeck < Decks::Base
        CHARACTER_MAPPING = {
          ranger: Characters::Ranger.new,
          thief: Characters::Thief.new,
          tinker: Characters::Tinker.new
        }.freeze

        def generate_deck
          @deck = CHARACTER_MAPPING.values
        end
      end
    end
  end
end
