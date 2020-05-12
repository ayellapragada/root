# frozen_string_literal: true

module Root
  module Actions
    # Handles all hand revealing logic
    class ShowHand
      attr_reader :faction_showing, :faction_to_show

      def initialize(faction_showing, faction_to_show)
        @faction_showing = faction_showing
        @faction_to_show = faction_to_show
      end

      def call
        faction_to_show
          .player
          .be_shown_hand(faction_showing.hand)
        add_history
      end

      def add_history
        faction_showing.player.add_to_history(
          :f_reveal_hand,
          faction_to_show: faction_to_show.faction_symbol
        )
        true
      end
    end
  end
end
