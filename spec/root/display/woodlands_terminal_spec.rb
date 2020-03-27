# frozen_string_literal: true

RSpec.describe Root::Display::WoodlandsTerminal do
  describe '#display' do
    it 'renders a board' do
      game = Root::Game.default_game

      place_mice_tokens_for_display(game)
      place_vagabond_token_for_display(game)
      game.setup
      game.render

      d = Root::Display::WoodlandsTerminal.new(game)
      expect(d.display).to eq('')
    end
  end

  def place_mice_tokens_for_display(game)
    mice = game.players.fetch_player(:mice).faction
    board = game.board
    clearing = board.clearings[:seven]

    board.place_token(mice.sympathy.pop, clearing)
    3.times { board.place_meeple(mice.meeples.pop, clearing) }
  end

  # Effectively this is just for test
  # Normally we won't have three vagabondos
  # Maximum we'll have 2, so we're just displaying all options
  def place_vagabond_token_for_display(game)
    player = game.players.fetch_player(:vagabond)
    vagabond = player.faction
    allow(player).to receive(:pick_option).and_return(0)
    board = game.board
    meeple = vagabond.meeples.first

    forest_f = board.forests[:f]
    board.place_meeple(meeple, forest_f)
    board.place_meeple(meeple, forest_f)
  end
end
