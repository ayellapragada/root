# frozen_string_literal: true

RSpec.describe Root::Cards::Item do
  describe '#initialize' do
    it 'always has a suit' do
      card = Root::Cards::Item.new(suit: :fox, craft: [:fox], item: :tea, vp: 2)

      expect(card.suit).to eq(:fox)
      expect(card.craft).to eq([:fox])
      expect(card.item).to eq(:tea)
      expect(card.vp).to be(2)
    end
  end
end
