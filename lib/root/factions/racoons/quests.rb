# frozen_string_literal: true

module Root
  module Factions
    module Racoons
      # module for catable methods
      # probably just color tbh
      class Quests
        attr_reader :deck, :active_quests

        def initialize
          @deck = Factions::Racoons::QuestDeck.new
          @active_quests = []
        end

        def setup
          active_quests.concat(deck.draw_from_top(3))
        end
      end
    end
  end
end
