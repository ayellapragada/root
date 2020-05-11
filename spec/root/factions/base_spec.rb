# frozen_string_literal: true

RSpec.describe Root::Factions::Base do
  let(:cat_player) { Root::Players::Computer.for('Cat', :cats) }
  let(:cat_faction) { cat_player.faction }
  let(:board) { cat_player.board }
  let(:clearings) { board.clearings }
  let(:mouse_player) { Root::Players::Computer.for('Sneak', :mice) }
  let(:mouse_faction) { mouse_player.faction }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }
  let(:racoon_player) { Root::Players::Computer.for('Racoon', :racoon) }
  let(:racoon_faction) { racoon_player.faction }

  describe '#victory_points=' do
    it 'can not change again once dominance' do
      dominance = Root::Cards::Dominance.new(suit: :fox)
      other_dominance = Root::Cards::Dominance.new(suit: :bird)
      mouse_faction.play_card(dominance)

      mouse_faction.gain_vps(1)
      expect(mouse_faction.victory_points).to eq(:fox)

      mouse_faction.play_card(other_dominance)
      expect(mouse_faction.victory_points).to eq(:fox)
    end
  end

  describe '#check_for_dominance' do
    it 'raises dominance when win condition is achieved' do
      dominance = Root::Cards::Dominance.new(suit: :fox)
      cat_faction.play_card(dominance)

      cat_faction.place_meeple(clearings[:one])
      cat_faction.place_meeple(clearings[:six])
      cat_faction.place_meeple(clearings[:eight])

      expect { cat_faction.birdsong }
        .to raise_error(Root::Errors::WinConditionReached)
    end
  end
end
