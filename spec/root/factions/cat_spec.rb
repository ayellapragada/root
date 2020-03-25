# frozen_string_literal: true

RSpec.describe Root::Factions::Cat do
  describe '.handle_faction_token_setup' do
    it 'gives faction 25 meeples, and then 6 buildings of each type' do
      player = Root::Players::Human.for('Sneak', :cats)
      faction = player.faction

      expect(faction.meeples.count).to eq(25)

      expect(faction.recruiters.count).to eq(6)
      expect(faction.sawmills.count).to eq(6)
      expect(faction.workshops.count).to eq(6)

      expect(faction.wood.count).to eq(8)
    end
  end

  describe '.setup' do
    it 'sets a keep in the corner' do
      board = Root::Boards::Woodlands.new
      player = Root::Players::Human.for('Sneak', :cats)
      faction = player.faction
      allow(player).to receive(:pick_option).and_return(0)
      expect(board.keep_in_corner?).to be false

      player.setup(board)

      expect(board.keep_in_corner?).to be true
      expect(faction.keep).to be_empty
    end

    it 'sets a sawmill, recruiter, and workshop in adjacent clearing' do
      board = Root::Boards::Woodlands.new
      player = Root::Players::Human.for('Sneak', :cats)
      faction = player.faction
      allow(player).to receive(:pick_option).and_return(0)

      player.setup(board)

      clearing = board.corner_with_keep
      expect(clearing_has_building(clearing, :recruiter)).to be true
      expect(clearing_has_building(clearing, :sawmill)).to be true
      expect(clearing_has_building(clearing, :workshop)).to be true
      expect(faction.recruiters.count).to be(5)
      expect(faction.sawmills.count).to be(5)
      expect(faction.workshops.count).to be(5)
    end

    it 'sets 11 warrior in all clearings except directly across' do
      board = Root::Boards::Woodlands.new
      player = Root::Players::Human.for('Sneak', :cats)
      faction = player.faction
      allow(player).to receive(:pick_option).and_return(0)

      player.setup(board)

      keep_clearing = board.clearing_across_from_keep
      other_clearings = board.clearings_other_than(keep_clearing)
      expect(clearings_have_one_cat_meeple?(other_clearings)).to be true
      expect(faction.meeples.count).to eq(14)
      expect(keep_clearing.meeples.count).to eq(0)
    end
  end

  def clearing_has_building(clearing, type)
    clearing.includes_building?(type) ||
      clearing.adjacents.one? { |adj| adj.includes_building?(type) }
  end

  def clearings_have_one_cat_meeple?(clearings)
    clearings.all? do |cl|
      cl.meeples.count == 1 && cl.meeples.first.faction == :cat
    end
  end
end
