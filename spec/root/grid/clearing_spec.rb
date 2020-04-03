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

  describe '#ruled_by' do
    context 'with the default conditions' do
      it 'is ruled by people with most tokens' do
        clearing = Root::Grid::Clearing.new(
          priority: 1,
          suit: :bunny,
          slots: 3
        )
        clearing.create_building(Root::Factions::Cats::Sawmill.new)
        clearing.place_meeple(Root::Pieces::Meeple.new(:cats))
        clearing.place_meeple(Root::Pieces::Meeple.new(:birds))

        expect(clearing.ruled_by).to eq(:cats)
      end

      context 'when tied' do
        it 'is ruled by no one' do
          clearing = Root::Grid::Clearing.new(
            priority: 1,
            suit: :bunny,
            slots: 3
          )
          clearing.place_meeple(Root::Pieces::Meeple.new(:cats))
          clearing.place_meeple(Root::Factions::Mice::Base.new(:mice))

          expect(clearing.ruled_by).to eq(nil)
        end
      end
    end

    context 'when birdies are involved' do
      it 'gives birds the win on a tie' do
        clearing = Root::Grid::Clearing.new(
          priority: 1,
          suit: :bunny,
          slots: 3
        )
        clearing.create_building(Root::Factions::Cats::Sawmill.new)
        clearing.place_meeple(Root::Pieces::Meeple.new(:cats))
        clearing.create_building(Root::Factions::Birds::Roost.new)
        clearing.place_meeple(Root::Pieces::Meeple.new(:birds))

        expect(clearing.ruled_by).to eq(:birds)
      end
    end

    context 'when a ruin is involved' do
      it 'does not count the ruin ' do
        clearing = Root::Grid::Clearing.new(
          priority: 1,
          suit: :bunny,
          slots: 3,
          ruin: true
        )
        clearing.place_meeple(Root::Pieces::Meeple.new(:cats))

        expect(clearing.ruled_by).to eq(:cats)
      end
    end

    # ohoho for future me
    # context 'when lizards are involved' do
    #   it 'gives it to the lizardos over all else'
    # end
  end

  describe '#connected_wood' do
    it 'checks adjacents and then some to find all connected paths' do
      clearings = Root::Boards::Base.new.clearings
      # connected
      clearings[:one].place_meeple(Root::Pieces::Meeple.new(:cats))
      clearings[:one].place_token(Root::Factions::Cats::Wood.new)
      clearings[:five].place_meeple(Root::Pieces::Meeple.new(:cats))
      clearings[:five].place_token(Root::Factions::Cats::Wood.new)
      clearings[:two].place_meeple(Root::Pieces::Meeple.new(:cats))
      clearings[:two].place_token(Root::Factions::Cats::Wood.new)

      # not connected
      clearings[:three].place_meeple(Root::Pieces::Meeple.new(:cats))
      clearings[:three].place_token(Root::Factions::Cats::Wood.new)

      expect(clearings[:one].connected_wood)
        .to match_array([clearings[:one], clearings[:five], clearings[:two]])
    end
  end
end
