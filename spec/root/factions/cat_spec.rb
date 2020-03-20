# frozen_string_literal: true

RSpec.describe Root::Factions::Cat do
  describe '.setup' do
    it 'sets a keep in the corner' do
      board = Root::Boards::Woodlands.new
      player = Root::Players::Human.for('Sneak', :cats)
      allow(player).to receive(:pick_option).and_return(0)

      player.setup(board)

      expect(board.keep_in_corner?).to be true
    end
  end
end
