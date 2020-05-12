# frozen_string_literal: true

RSpec.describe Root::Cards::Base do
  describe '#initialize' do
    it 'always has a suit' do
      card = Root::Cards::Base.new(suit: :fox)
      expect(card.suit).to be(:fox)
      expect(card.body).to eq(' ')
    end
  end
end
