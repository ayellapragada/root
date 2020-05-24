# frozen_string_literal: true

module Root
  module Boards
    # This is to allow an adapater to plug in here, and update its DB as needed
    class MockBoardUpdater
      attr_accessor :board

      def initialize(*); end

      def add(clearing, type); end

      def remove(clearing, type); end

      def update_items; end
    end
  end
end
