# frozen_string_literal: true

RSpec.describe Root::Cards::Ambush do
  let(:mouse_player) { Root::Players::Computer.for('Sneak', :mice) }
  let(:mouse_faction) { mouse_player.faction }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }
  let(:cat_player) { Root::Players::Computer.for('Cat', :cats) }
  let(:cat_faction) { cat_player.faction }
  let(:racoon_player) { Root::Players::Computer.for('Racoon', :racoon) }
  let(:racoon_faction) { racoon_player.faction }
  let(:clearings) { mouse_player.board.clearings }

  describe '#info' do
    it 'is hopefully helpful' do
      card = Root::Cards::Ambush.new(suit: :fox)
      expect(card.name).to eq('Ambush')
      expect(card.body).to eq('Deal 2 hits on Defense')
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
end
