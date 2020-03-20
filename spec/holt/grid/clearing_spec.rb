# frozen_string_literal: true

RSpec.describe Holt::Grid::Clearing do
  describe '.initialize' do
    it 'sets values for a clearing' do
      clearing = Holt::Grid::Clearing.new(
        priority: 1,
        suit: :bunny,
        slots: 2,
        ruin: true
      )

      expect(clearing.priority).to eq(1)
      expect(clearing.suit).to eq(:bunny)
      expect(clearing.ruin?).to eq(true)
      expect(clearing.adjacents).to eq([])
    end
  end

  describe '.add_path' do
    it 'creates a link between two adjacent clearings' do
      clearing_one = Holt::Grid::Clearing.new(priority: 1, suit: :fox, slots: 2)
      clearing_two = Holt::Grid::Clearing.new(priority: 2, suit: :fox, slots: 2)

      clearing_one.add_path(clearing_two)
      expect(clearing_one.adjacents).to eq([clearing_two])
      expect(clearing_two.adjacents).to eq([clearing_one])
    end
  end

  describe '.available_slots' do
    context 'without a ruin' do
      it 'counts all slots as available' do
        clearing = Holt::Grid::Clearing.new(priority: 1, suit: :fox, slots: 3)

        expect(clearing.available_slots).to eq(3)
      end
    end

    context 'with a ruin' do
      it 'counts the ruin as unavailable' do
        clearing = Holt::Grid::Clearing.new(
          priority: 1,
          suit: :fox,
          slots: 3,
          ruin: true
        )

        expect(clearing.available_slots).to eq(2)
      end
    end
  end
end
