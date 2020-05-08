# frozen_string_literal: true

RSpec.describe Root::Factions::Racoons::Characters::Tinker do
  let(:player) { Root::Players::Computer.for('Sneak', :racoon) }
  let(:faction) { player.faction }
  let(:char) { faction.character }
  let(:board) { player.board }
  let(:clearings) { board.clearings }
  let(:forests) { board.forests }
  let(:mouse_player) { Root::Players::Computer.for('Bird', :mice) }
  let(:mouse_faction) { mouse_player.faction }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }
  let(:cat_player) { Root::Players::Computer.for('Cat', :cats) }
  let(:cat_faction) { cat_player.faction }

  before { faction.quick_set_character(:tinker) }

  describe '#special' do
    it 'can take any card from discard matching clearing suit or bird' do
      allow(player).to receive(:pick_option).and_return(0)

      faction.place_meeple(clearings[:one])
      fox_card = Root::Cards::Base.new(suit: :fox)
      mouse_card = Root::Cards::Base.new(suit: :mouse)
      bird_card = Root::Cards::Base.new(suit: :bird)

      faction.hand << fox_card
      faction.hand << mouse_card
      faction.hand << bird_card

      expect(char.special_options).to eq([])
      expect(char.can_special?).to be false

      faction.discard_card(fox_card)
      faction.discard_card(mouse_card)
      faction.discard_card(bird_card)

      expect(char.special_options).to eq([fox_card, bird_card])
      expect(char.can_special?).to be true
      expect { char.special }
        .to change(faction, :hand_size)
        .by(1)
        .and change { faction.deck.discard.count }
        .by(-1)
    end
  end
end
