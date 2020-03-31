# frozen_string_literal: true

RSpec.describe Root::Display::WoodlandsTerminal do
  describe '#display' do
    it 'renders a board' do
      game = Root::Game.default_game

      place_mice_tokens_for_display(game)
      place_vagabond_token_for_display(game)
      game.setup
      mock_clearing_options(game)

      game.print_display = true
      expect(game.render).to be nil
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

  # rubocop:disable all
  def mock_clearing_options(game)
    board = game.board
    allow_any_instance_of(Root::Display::WoodlandsTerminal)
      .to receive(:clearing_options)
      .and_return(
        [
          board.clearings[:one],
          board.clearings[:eleven],
          board.forests[:e]
        ]
    )
    # rubocop:enable all
  end
end
