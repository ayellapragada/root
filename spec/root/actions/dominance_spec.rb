# frozen_string_literal: true

RSpec.describe Root::Actions::Dominance do
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

  describe '#check' do
    it 'does not raise if win condition is not reached' do
      dominance = Root::Cards::Dominance.new(suit: :fox)
      cat_faction.play_card(dominance)

      cat_faction.place_meeple(clearings[:one])
      cat_faction.place_meeple(clearings[:eight])

      expect { described_class.new(cat_faction).check }.not_to raise_error
    end

    context 'when dominance suit is bird' do
      it 'checks 2 opposite corners' do
        dominance = Root::Cards::Dominance.new(suit: :bird)
        cat_faction.play_card(dominance)

        cat_faction.place_meeple(clearings[:one])
        cat_faction.place_meeple(clearings[:three])

        expect { described_class.new(cat_faction).check }
          .to raise_error(Root::Errors::WinConditionReached)
      end
    end

    context 'when dominance suit is coalition for racoon' do
      it 'does nothing' do
        allow(racoon_player).to receive(:pick_option).and_return(0)
        dominance = Root::Cards::Dominance.new(suit: :bird)
        racoon_faction.play_card(dominance)

        expect { described_class.new(cat_faction).check }.not_to raise_error
      end
    end
  end
end
