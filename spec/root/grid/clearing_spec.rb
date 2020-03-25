# frozen_string_literal: true

RSpec.describe Root::Grid::Clearing do
  describe '#initialize' do
    it 'sets values for a clearing' do
      clearing = Root::Grid::Clearing.new(
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

  describe '#add_path' do
    it 'creates a link between two adjacent clearings' do
      clearing_one = Root::Grid::Clearing.new(priority: 1, suit: :fox, slots: 2)
      clearing_two = Root::Grid::Clearing.new(priority: 2, suit: :fox, slots: 2)

      clearing_one.add_path(clearing_two)
      expect(clearing_one.adjacents).to eq([clearing_two])
      expect(clearing_two.adjacents).to eq([clearing_one])
    end
  end

  describe '#available_slots' do
    context 'without a ruin' do
      it 'counts all slots as available' do
        clearing = Root::Grid::Clearing.new(priority: 1, suit: :fox, slots: 3)

        expect(clearing.available_slots).to eq(3)
      end
    end

    context 'with a ruin' do
      it 'counts the ruin as unavailable' do
        clearing = Root::Grid::Clearing.new(
          priority: 1,
          suit: :fox,
          slots: 3,
          ruin: true
        )

        expect(clearing.available_slots).to eq(2)
      end
    end
  end

  describe '#create_building' do
    context 'when there is room' do
      it 'creates a building' do
        clearing = Root::Grid::Clearing.new(
          priority: 1,
          suit: :bunny,
          slots: 1
        )

        building = Root::Factions::Cats::Workshop.new

        clearing.create_building(building)
        expect(clearing.includes_building?(:workshop)).to be true
      end
    end

    context 'when there is no room' do
      it 'does not create a building' do
        clearing = Root::Grid::Clearing.new(
          priority: 1,
          suit: :bunny,
          slots: 1,
          ruin: true
        )

        building = Root::Factions::Cats::Workshop.new

        clearing.create_building(building)
        expect(clearing.includes_building?(:workshop)).to be false
      end
    end
  end

  describe '#buildings_with_empties' do
    it 'fills available slots with empty slots for display' do
      clearing = Root::Grid::Clearing.new(
        priority: 1,
        suit: :bunny,
        slots: 3,
        ruin: true
      )

      expect(clearing.buildings_with_empties.map(&:type))
        .to eq(%i[ruin emptyslot emptyslot])
      expect(clearing.buildings.map(&:type)).to eq(%i[ruin])
    end
  end
end
