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

  describe '#take_dominance_opts' do
    it 'requires an available dominance with matching suit card in hand' do
      dominance = Root::Cards::Dominance.new(suit: :fox)
      mouse_player.deck = cat_player.deck

      mouse_faction.hand << dominance
      expect(cat_faction.take_dominance?).to be false

      mouse_faction.discard_card(dominance)
      expect(cat_faction.take_dominance?).to be false

      cat_faction.hand << Root::Cards::Base.new(suit: :mouse)
      cat_faction.hand << Root::Cards::Base.new(suit: :fox)
      expect(cat_faction.take_dominance_opts).to eq([dominance])
      expect(cat_faction.take_dominance?).to be true
    end
  end

  describe '#play_dominance?' do
    it 'requires a dominance card in hand and at least 10 victory points' do
      dominance = Root::Cards::Dominance.new(suit: :fox)

      expect(cat_faction.play_dominance?).to be false

      cat_faction.hand << dominance
      expect(cat_faction.play_dominance?).to be false

      cat_faction.victory_points = 10
      expect(cat_faction.play_dominance?).to be true

      cat_faction.discard_card(dominance)
      expect(cat_faction.play_dominance?).to be false
    end

    context 'when dominance already played' do
      it 'cannot be played' do
        dominance = Root::Cards::Dominance.new(suit: :fox)
        cat_faction.play_card(dominance)

        expect(cat_faction.play_dominance?).to be false
      end
    end
  end

  describe '#take_dominance' do
    it 'lets a faction take an available dominance card' do
      allow(cat_player).to receive(:pick_option).and_return(0)

      dominance = Root::Cards::Dominance.new(suit: :fox)
      cat_faction.hand << dominance
      cat_faction.discard_card(dominance)

      cat_faction.hand << Root::Cards::Base.new(suit: :fox)

      expect { cat_faction.take_dominance }
        .to change { cat_faction.deck.discard.count }.by(1)
      expect(cat_faction.hand).to eq([dominance])
      expect(cat_faction.deck.dominance[:fox][:card]).to be nil
    end
  end

  describe '#tax_collector?' do
    it 'requires 1 warrior on the board and the crafted improvement' do
      card = Root::Cards::Improvements::TaxCollector.new
      cat_faction.improvements << card
      expect(cat_faction.tax_collector?).to be false

      cat_faction.place_meeple(clearings[:one])
      expect(cat_faction.tax_collector?).to be true
    end
  end

  describe '#tax_collector' do
    it 'removes 1 warrior to draw 1 card' do
      allow(cat_player).to receive(:pick_option).and_return(0)

      card = Root::Cards::Improvements::TaxCollector.new
      cat_faction.improvements << card
      cat_faction.place_meeple(clearings[:one])

      expect { cat_faction.tax_collector }
        .to change(cat_faction, :hand_size)
        .by(1)
        .and change { clearings[:one].meeples_of_type(:cats).count }
        .by(-1)
    end
  end
end
