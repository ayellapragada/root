# frozen_string_literal: true

RSpec.describe Holt::Grid::Clearing do
  describe '.initialize' do
    it 'accepts a suit type, number of slots, and if a ruin is there' do
      clearing = Holt::Grid::Clearing.new(suit: :bunny, slots: 2, ruin: true)
      expect(clearing.suit).to eq(:bunny)
      expect(clearing.ruin?).to eq(true)
      expect(clearing.available_slots).to eq(1)
    end
  end
end
