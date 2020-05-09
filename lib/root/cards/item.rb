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

      # :nocov:
      def inspect
        "#{name_with_suit} - #{item.capitalize} | Craft: #{craft.join(', ')}, Victory Points: #{vp}"
      end
      # :nocov:

      def body
        "#{item.capitalize}, +#{vp} VPs"
      end
    end
  end
end
