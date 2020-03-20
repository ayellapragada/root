# frozen_string_literal: true

RSpec.describe Holt::Boards::Woodlands do
  describe '.initialize' do
    it 'creates board with correct clearing state' do
      board = Holt::Boards::Woodlands.new
      clearings = board.clearings.values

      expect(board.clearings).to be_truthy
      expect(clearings.select { |c| c.suit == :fox }.count).to be(4)
      expect(clearings.select { |c| c.suit == :mouse }.count).to be(4)
      expect(clearings.select { |c| c.suit == :rabbit }.count).to be(4)
    end
  end
end
