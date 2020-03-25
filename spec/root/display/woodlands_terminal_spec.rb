# frozen_string_literal: true

RSpec.describe Root::Display::WoodlandsTerminal do
  describe '#display' do
    it 'renders a board' do
      game = Root::Game.default_game
      human_player = game.players.fetch_player(:mice)
      allow(human_player).to receive(:pick_option).and_return(0)

      game.setup
      game.render

      d = Root::Display::WoodlandsTerminal.new(game)
      expect(d.display).to eq('')
    end
  end
end
