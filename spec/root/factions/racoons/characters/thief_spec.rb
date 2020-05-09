# frozen_string_literal: true

RSpec.describe Root::Factions::Racoons::Characters::Thief do
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

  before { faction.quick_set_character(:thief) }

  describe '#special_options' do
    it 'requires another faction in clearing with cards in hand' do
      faction.place_meeple(clearings[:one])
      cat_faction.place_meeple(clearings[:one])
      bird_faction.place_meeple(clearings[:one])
      players = Root::Players::List.new(player, cat_player, bird_player)
      player.players = players

      cat_faction.hand << Root::Cards::Base.new(suit: :fox)
      cat_faction.hand << Root::Cards::Base.new(suit: :mouse)
      expect(char.special_options).to eq([:cats])
    end

    context 'without any cards' do
      it 'can not steal' do
        faction.place_meeple(clearings[:one])
        cat_faction.place_meeple(clearings[:one])
        bird_faction.place_meeple(clearings[:one])
        players = Root::Players::List.new(player, cat_player, bird_player)
        player.players = players

        expect(faction.can_special?).to be false
        expect(char.special_options).to be_empty
      end
    end
  end

  describe '#special' do
    it 'requires another faction in clearing with cards in hand' do
      allow(player).to receive(:pick_option).and_return(0)

      faction.place_meeple(clearings[:one])
      cat_faction.place_meeple(clearings[:one])
      bird_faction.place_meeple(clearings[:one])
      players = Root::Players::List.new(player, cat_player, bird_player)
      player.players = players

      cat_faction.hand << Root::Cards::Base.new(suit: :fox)
      cat_faction.hand << Root::Cards::Base.new(suit: :mouse)

      expect { faction.use_special }
        .to change(faction, :hand_size)
        .by(1)
        .and change(cat_faction, :hand_size)
        .by(-1)
    end
  end
end
