# frozen_string_literal: true

require 'singleton'

module Root
  module ActionTree
    # For consolidating choices related code
    class Choice
      attr_reader :val
      attr_accessor :parent, :key, :children

      def initialize(key: nil, val: nil, parent: nil, children: [])
        @key = key
        @val = val
        @parent = parent
        @children = children.map { |child| Choice.new(val: child, parent: self) }
      end

      def find_child(val)
        children.find { |child| child.val == val }
      end

      def as_json
        {
          key: key,
          val: val,
          children: children.map(&:as_json)
        }
      end
    end
  end
end
