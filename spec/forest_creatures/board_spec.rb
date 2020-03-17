# frozen_string_literal: true

RSpec.describe ForestCreatures::Board do
  it 'can access the board' do
    board = ForestCreatures::Board.new
    expect(board.wah).to be true
  end
end
