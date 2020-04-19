# frozen_string_literal: true

module Root
  module Boards
    # I think the items are the same for every map?
    # But I don't want to think about it all that much
    class ItemsGenerator
      def self.generate
        %i[
          boots boots
          satchel satchel
          crossbow hammer
          sword sword
          tea tea
          coin coin
        ]
      end
    end
  end
end
