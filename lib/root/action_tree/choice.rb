# frozen_string_literal: true

require 'singleton'

module Root
  module ActionTree
    # For consolidating choices related code
    class Choice
      attr_reader :val
      attr_accessor :parent, :key, :children, :info

      def initialize(key: nil, val: nil, info: nil, parent: nil)
        @key = key
        @val = val
        @info = info
        @parent = parent
        @children = []
      end

      def find_child(val)
        children.find { |child| child.val == val }
      end

      def as_json
        {
          key: key,
          val: val&.inspect,
          info: info || {},
          children: children.map(&:as_json)
        }
      end
    end
  end
end
