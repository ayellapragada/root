# frozen_string_literal: true

module Root
  module Factions
    module Racoons
      # probably just color tbh
      class CompletedQuests
        def initialize
          @completed_quests = { mouse: [], fox: [], rabbit: [] }
        end

        def [](value)
          @completed_quests[value]
        end

        def complete_quest(quest)
          @completed_quests[quest.suit] << quest
        end
      end
    end
  end
end
