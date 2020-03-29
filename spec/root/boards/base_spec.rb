# frozen_string_literal: true

RSpec.describe Root::Boards::Base do
  describe '.initialize' do
    it 'creates board with correct clearing state' do
      board = Root::Boards::Base.new
      clearings = board.clearings.values

      expect(board.clearings).to be_truthy
      expect(clearings.select { |c| c.suit == :fox }.count).to be(4)
      expect(clearings.select { |c| c.suit == :mouse }.count).to be(4)
      expect(clearings.select { |c| c.suit == :bunny }.count).to be(4)
    end

    # We're not going to test them ALL.
    it 'populates paths between clearings' do
      board = Root::Boards::Base.new

      clearing_one = board.clearings[:one]
      clearing_two = board.clearings[:two]
      clearing_five = board.clearings[:five]
      expect(clearing_one.adjacents.include?(clearing_five)).to be true
      expect(clearing_five.adjacents.include?(clearing_two)).to be true
    end

    it 'creates board with correct number of forests' do
      board = Root::Boards::Base.new

      expect(board.forests.values.count).to be(7)
    end

    it 'populates paths between forests and clearings' do
      board = Root::Boards::Base.new

      forest_f = board.forests[:f]
      forest_a = board.forests[:a]
      forest_c = board.forests[:c]
      clearing_one = board.clearings[:one]

      expect(clearing_one.adjacents.include?(forest_a)).to be false
      expect(clearing_one.adjacent_forests.include?(forest_a)).to be true
      expect(forest_a.adjacent_forests.include?(forest_c)).to be true
      expect(forest_a.adjacent_forests.include?(forest_f)).to be false
    end
  end
end
