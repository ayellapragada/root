# frozen_string_literal: true

RSpec.describe Root::Boards::Woodlands do
  describe '.initialize' do
    it 'creates board with correct clearing state' do
      board = Root::Boards::Woodlands.new
      clearings = board.clearings.values

      expect(board.clearings).to be_truthy
      expect(clearings.select { |c| c.suit == :fox }.count).to be(4)
      expect(clearings.select { |c| c.suit == :mouse }.count).to be(4)
      expect(clearings.select { |c| c.suit == :rabbit }.count).to be(4)
    end

    # We're not going to test them ALL.
    # This may change I don't want to be bogged down.
    it 'populates paths between clearings' do
      board = Root::Boards::Woodlands.new

      clearing_one = board.clearings[:one]
      clearing_two = board.clearings[:two]
      clearing_five = board.clearings[:five]
      expect(clearing_one.adjacents.include?(clearing_five)).to be true
      expect(clearing_five.adjacents.include?(clearing_two)).to be true
    end
  end
end
