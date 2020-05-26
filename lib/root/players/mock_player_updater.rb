module Root
  module Players
    # This is what I want to be able to get subbed in from the Rails Player
    class MockPlayerUpdater
      # The client injects something here.
      def update(_data, *); end
    end
  end
end
