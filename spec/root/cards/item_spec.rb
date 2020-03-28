# frozen_string_literal: true

RSpec.describe Root::Cards::Item do
  describe '#initialize' do
    it 'always has a suit' do
      card = Root::Cards::Item.new(suit: :fox)
      expect(card.suit).to be(:fox)
    end
  end
end
