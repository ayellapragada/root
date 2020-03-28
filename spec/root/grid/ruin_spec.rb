# frozen_string_literal: true

RSpec.describe Root::Grid::Ruin do
  describe '#contains_item?' do
    context 'with items' do
      it do
        ruin = Root::Grid::Ruin.new
        ruin.items << :tea
        expect(ruin.contains_item?).to be true
      end
    end

    context 'without items' do
      it do
        ruin = Root::Grid::Ruin.new
        expect(ruin.contains_item?).to be false
      end
    end
  end
end
