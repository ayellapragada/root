# frozen_string_literal: true

module Root
  module Decks
    # Inject something to allow the game to update DB
    class MockDecksUpdater
      attr_accessor :decks

      def initialize(*); end

      def update; end

      def full_update; end
    end
  end
end
