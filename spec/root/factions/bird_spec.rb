# frozen_string_literal: true

RSpec.describe Root::Factions::Bird do
  describe '#handle_faction_token_setup' do
    it 'gives faction 20 meeples,7 roosts, 2 loyal viziers, and 4 leaders' do
      player = Root::Players::Human.for('Sneak', :birds)
      faction = player.faction

      expect(faction.meeples.count).to eq(20)
      expect(faction.roosts.count).to eq(7)
      expect(faction.viziers.count).to eq(2)
      leaders = faction.leaders.map(&:leader)
      expect(leaders).to match_array(%i[builder charismatic commander despot])
    end
  end

  describe '#setup' do
    context 'when there is a keep on the board' do
      it 'sets up opposite to keep' do
        board = Root::Boards::Woodlands.new
        cat_player = Root::Players::Human.for('Other', :cats)
        cat_faction = cat_player.faction
        allow(cat_player).to receive(:pick_option).and_return(0)
        cat_faction.build_keep(board)

        player = Root::Players::Human.for('Sneak', :birds)
        allow(player).to receive(:pick_option).and_return(0)
        player.setup(board)

        initial_bird_clearing = board.clearing_across_from_keep
        initial_meeples = initial_bird_clearing.meeples
        expect(initial_bird_clearing.includes_building?(:roost)).to be true
        expect(has_only_six_bird_warriors(initial_meeples)).to be true
      end
    end

    context 'when there is not a keep on the board' do
      it 'sets up in a corner it chooses' do
        board = Root::Boards::Woodlands.new
        player = Root::Players::Human.for('Sneak', :birds)
        allow(player).to receive(:pick_option).and_return(0)

        player.setup(board)

        initial_bird_clearing = board.corner_with_roost
        initial_meeples = initial_bird_clearing.meeples
        expect(initial_bird_clearing.includes_building?(:roost)).to be true
        expect(has_only_six_bird_warriors(initial_meeples)).to be true
      end
    end

    it 'lets player picks a starting leader' do
      board = Root::Boards::Woodlands.new
      cat_faction = Root::Players::Computer.for('Other', :cats).faction
      cat_faction.build_keep(board)

      player = Root::Players::Human.for('Sneak', :birds)
      allow(player).to receive(:pick_option).and_return(0)
      faction = player.faction

      expect(faction.current_leader).to be_nil
      player.setup(board)
      expect(faction.current_leader).not_to be nil
    end

    it 'starts initial decree for player with viziers' do
      board = Root::Boards::Woodlands.new
      cat_faction = Root::Players::Computer.for('Other', :cats).faction
      cat_faction.build_keep(board)

      player = Root::Players::Human.for('Sneak', :birds)
      faction = player.faction
      allow(player).to receive(:pick_option).and_return(0)
      expect(faction.decree).to be_empty

      player.setup(board)

      expect(faction.decree[:recruit]).to eq([:bird])
      expect(faction.decree[:move]).to eq([:bird])
    end
  end

  describe '#change_current_leader' do
    context 'when not given a leader to switch to' do
      it 'removes current leader and picks a new one' do
        player = Root::Players::Human.for('Sneak', :birds)
        faction = player.faction
        allow(player).to receive(:pick_option).and_return(0)
        expect(faction.current_leader).to be nil

        faction.change_current_leader
        expect(faction.current_leader).not_to be nil
        old_leader = faction.current_leader
        faction.change_current_leader
        expect(faction.current_leader).not_to be old_leader
        expect(faction.used_leaders).to match_array([old_leader])
        faction.change_current_leader
        faction.change_current_leader
        expect(faction.used_leaders.count).to eq(3)
        faction.change_current_leader
        expect(faction.used_leaders.count).to eq(0)
      end
    end

    context 'when given a leader to switch to' do
      it 'switches current leader to given one' do
        faction = Root::Players::Computer.for('Sneak', :birds).faction
        expect(faction.current_leader).to be nil

        faction.change_current_leader(:despot)
        expect(faction.current_leader.leader).to eq(:despot)
        faction.change_current_leader(:builder)

        expect(faction.current_leader.leader).to eq(:builder)
        expect(faction.used_leaders.first.leader).to eq(:despot)
      end
    end
  end

  describe '#change_viziers_with_leader' do
    it 'sets the viziers into the decree based off leader' do
      faction = Root::Players::Computer.for('Sneak', :birds).faction
      faction.change_current_leader(:despot)

      faction.change_viziers_with_leader

      expect(faction.decree.decree).to eq(
        recruit: [],
        move: [:bird],
        battle: [],
        build: [:bird]
      )
    end
  end

  def has_only_six_bird_warriors(meeples)
    meeples.count == 6 && meeples.all? { |w| w.faction == :bird }
  end
end
