# frozen_string_literal: true

module Root
  module Factions
    module Racoons
      # This is just a generic data struct for quest cards
      # Only racoon uses really
      class QuestCard < Cards::Base
        attr_reader :suit, :items

        def initialize(suit:, items:, name:)
          super(suit: suit, name: name)
          @items = items
        end

        def inspect
          "#{name}: #{items.map(&:capitalize).join(', ')}"
        end
      end
    end
  end
end
