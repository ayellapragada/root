# frozen_string_literal: true

RSpec.describe ForestCreatures::Game do
  describe '#initialize' do
    context 'when given characters' do
      it 'sets characters and board' do
        p1 = ForestCreatures::Players::Human.for('Akshith', :birds)
        p2 = ForestCreatures::Players::Computer.for('Steve', :cats)
        game = ForestCreatures::Game.new(player1: p1, player2: p2)

        expect(game.player1).to be_truthy
        expect(game.player2).to be_truthy
        expect(game.board).to be_truthy
      end
    end

    # xit 'takes a board with a default grid'
  end

  # xdescribe '#setup' do
  #   it 'calls board setup'
  #   it 'calls character specific setup'
  # end
end
