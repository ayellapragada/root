# frozen_string_literal: true

RSpec.describe Root::Players::Human do
  describe '.pick_option' do
    it 'delegates correctly' do
      player = Root::Players::Human.for('Sneak', :mice)
      allow(player.display).to receive(:pick_option).and_return(0)

      expect(player.pick_option(%w[foo bar])).to be(0)
    end
  end
end
