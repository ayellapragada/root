# frozen_string_literal: true

require_relative './base'

module Root
  module Cards
    # This is the base card format.
    # Lots of things are going to be optional, so that's fun.
    # We got item cards, actives, and improvements
    class Item < Base
      attr_reader :craft, :item, :vp

      def initialize(suit:, name: 'Item', craft: nil, item:, vp:)
        super(suit: suit, name: name)
        @craft = craft
        @item = item
        @vp = vp
      end

      def faction_craft(fac)
        fac.board.items.delete_first(item)
        fac.board.updater.update_items
        fac.discard_card(self)
        fac.gain_vps(fac.handle_item_vp(self))
        fac.make_item(item)
        fac.player.add_to_history(:f_item_select, item: item, vp: vp)
      end

      def craftable?(board)
        board.items.include?(item)
      end
    end
  end
end
