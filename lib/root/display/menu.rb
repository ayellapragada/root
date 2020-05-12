# frozen_string_literal: true

module Root
  module Display
    # Code to handle the popup menu
    # This is reserved for things like
    # help, discard, etc
    # But also now being used to quickly show the hand in a reveal
    class Menu
      attr_reader :text
      def initialize(text)
        @text = text
      end

      # :nocov:
      def display
        IO.popen('less', 'w') { |f| f.puts file }
      end
      # :nocov:
    end
  end
end
