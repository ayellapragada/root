# frozen_string_literal: true

module Root
  module Factions
    module Racoons
      # module for catable methods
      # probably just color tbh
      class Quests
        attr_reader :deck, :active_quests

        def initialize(quests: nil, active_quests: [], skip_generate: false)
          @deck = Factions::Racoons::QuestDeck.new(deck: quests, skip_generate: skip_generate)
          @active_quests = active_quests
          3.times { draw_new_card } if active_quests.empty?
        end

        def draw_new_card
          active_quests.concat(deck.draw_from_top)
        end

        def complete_quest(quest)
          active_quests.delete_first(quest)
        end
      end
    end
  end
end
