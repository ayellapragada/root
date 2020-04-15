# frozen_string_literal: true

module Root
  module Factions
    module Vagabonds
      # This is just a generic data struct for quest cards
      # Only vagabond uses really
      class QuestCard < Cards::Base
        attr_reader :suit, :items

        def initialize(suit:, items:)
          super(suit: suit)
          @items = items
        end
      end
    end
  end
end
