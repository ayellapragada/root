# frozen_string_literal: true

RSpec.describe Root::Cards::Ambush do
  let(:player) { Root::Players::Computer.for('Cat', :cats) }
  let(:faction) { player.faction }
  let(:mouse_player) { Root::Players::Computer.for('Sneak', :mice) }
  let(:mouse_faction) { mouse_player.faction }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }
  let(:racoon_player) { Root::Players::Computer.for('Racoon', :racoon) }
  let(:racoon_faction) { racoon_player.faction }
  let(:clearings) { player.board.clearings }

  describe '#info' do
    it 'is hopefully helpful' do
      card = Root::Cards::Ambush.new(suit: :fox)

      expect(card.name).to eq('Ambush')
    end
  end

  describe '#faction_craft' do
    it 'changes factions victory conditions' do
      card = Root::Cards::Dominance.new(suit: :fox)
      # mobilize is first, second is play_dominance :)
      allow(mouse_player).to receive(:pick_option).and_return(1, 0)

      mouse_faction.victory_points = 10
      mouse_faction.hand << card

      mouse_faction.daylight

      expect(mouse_faction.victory_points).to eq(:fox)
      expect(mouse_faction.win_via_dominance?).to be true
    end
  end

  describe '#ambush' do
    it 'if defender plays an ambush card, does 2 damage' do
      allow(player).to receive(:pick_option).and_return(0)
      allow(bird_player).to receive(:pick_option).and_return(0)

      players = Root::Players::List.new(player, bird_player)
      player.players = players

      battle_cl = clearings[:one]
      faction.place_meeple(battle_cl)
      faction.place_meeple(battle_cl)
      faction.place_meeple(battle_cl)
      bird_faction.place_meeple(battle_cl)
      bird_faction.place_meeple(battle_cl)

      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(2, 2)

      bird_faction.hand << Root::Cards::Ambush.new(suit: :fox)

      faction.battle

      expect(battle_cl.meeples_of_type(:cats).count).to eq(0)
      expect(battle_cl.meeples_of_type(:birds).count).to eq(1)
      expect(bird_faction.hand_size).to eq(0)
    end

    it 'can be cancelled if the attacker plays an ambush card' do
      allow(player).to receive(:pick_option).and_return(0)
      allow(bird_player).to receive(:pick_option).and_return(0)

      players = Root::Players::List.new(player, bird_player)
      player.players = players

      battle_cl = clearings[:one]
      faction.place_meeple(battle_cl)
      faction.place_meeple(battle_cl)
      faction.place_meeple(battle_cl)
      bird_faction.place_meeple(battle_cl)
      bird_faction.place_meeple(battle_cl)

      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(2, 2)

      bird_faction.hand << Root::Cards::Ambush.new(suit: :fox)
      faction.hand << Root::Cards::Ambush.new(suit: :bird)

      faction.battle

      expect(battle_cl.meeples_of_type(:cats).count).to eq(1)
      expect(battle_cl.meeples_of_type(:birds).count).to eq(0)
      expect(faction.hand_size).to eq(0)
      expect(bird_faction.hand_size).to eq(0)
    end

    it 'ends battle immediately if all attacking warriors removed' do
      allow(player).to receive(:pick_option).and_return(0)
      allow(bird_player).to receive(:pick_option).and_return(0)

      players = Root::Players::List.new(player, bird_player)
      player.players = players

      battle_cl = clearings[:one]
      faction.place_meeple(battle_cl)
      faction.place_meeple(battle_cl)
      faction.place_sawmill(battle_cl)
      bird_faction.place_meeple(battle_cl)
      bird_faction.place_meeple(battle_cl)

      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(2, 2)

      bird_faction.hand << Root::Cards::Ambush.new(suit: :fox)

      faction.battle

      expect(battle_cl.meeples_of_type(:cats).count).to eq(0)
      expect(battle_cl.buildings_of_type(:sawmill).count).to eq(1)
      expect(battle_cl.meeples_of_type(:birds).count).to eq(2)
    end
  end
end
