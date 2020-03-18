# frozen_string_literal: true

RSpec.describe ForestCreatures::Board do
  describe '.default' do
    it 'returns the default initial board state' do
      expect(ForestCreatures::Board.default).to eq([[]])
    end
  end
end
