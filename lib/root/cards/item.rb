# frozen_string_literal: true

require_relative './base'

module Root
  module Cards
    # This is the base card format.
    # Lots of things are going to be optional, so that's fun.
    # We got item cards
    # We got actives
    # We got passives
    # I ain't consolidating that heck no
    class Item < Base
      attr_reader :craft, :item, :vp

      def initialize(suit:, name: 'Item', craft: nil, item:, vp:)
        super(suit: suit, name: name)
        @craft = craft
        @item = item
        @vp = vp
      end
    end
  end
end
