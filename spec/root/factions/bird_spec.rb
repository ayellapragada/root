# frozen_string_literal: true

RSpec.describe Root::Factions::Bird do
  describe '#handle_faction_token_setup' do
    it 'gives faction 20 meeples,7 roosts, 2 loyal viziers, and 4 leaders' do
      player = Root::Players::Human.for('Sneak', :birds)
      faction = player.faction

      expect(faction.meeples.count).to eq(20)
      expect(faction.roosts.count).to eq(7)
      expect(faction.viziers.count).to eq(2)
      expect(faction.leaders.count).to eq(4)
    end
  end

  describe '#setup' do
    context 'when there is a keep on the board' do
      it 'sets up opposite to keep' do
        board = Root::Boards::Woodlands.new
        cat_player = Root::Players::Human.for('Other', :cats)
        cat_faction = cat_player.faction
        allow(cat_player).to receive(:pick_option).and_return(0)
        cat_faction.build_keep(board)

        player = Root::Players::Human.for('Sneak', :birds)
        player.setup(board)

        initial_bird_clearing = board.clearing_across_from_keep
        initial_meeples = initial_bird_clearing.meeples
        expect(initial_bird_clearing.includes_building?(:roost)).to be true
        expect(has_only_six_bird_warriors(initial_meeples)).to be true
      end
    end

    context 'when there is not a keep on the board' do
      it 'sets up in a corner it chooses' do
        board = Root::Boards::Woodlands.new
        player = Root::Players::Human.for('Sneak', :birds)
        allow(player).to receive(:pick_option).and_return(0)

        player.setup(board)

        initial_bird_clearing = board.corner_with_roost
        initial_meeples = initial_bird_clearing.meeples
        expect(initial_bird_clearing.includes_building?(:roost)).to be true
        expect(has_only_six_bird_warriors(initial_meeples)).to be true
      end
    end
  end

  def has_only_six_bird_warriors(meeples)
    meeples.count == 6 && meeples.all? { |w| w.faction == :bird }
  end
end
