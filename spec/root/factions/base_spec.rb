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

  describe '#codebreakers?' do
    it 'requires other factions to have a card in hand' do
      players = Root::Players::List.new(cat_player, bird_player)
      cat_player.players = players

      card = Root::Cards::Improvements::Codebreakers.new
      cat_faction.improvements << card
      expect(cat_faction.codebreakers?).to be false

      bird_faction.hand << Root::Cards::Base.new(suit: :fox)
      expect(cat_faction.codebreakers?).to be true
    end
  end

  describe '#codebreakers' do
    it 'is shown other factions hand' do
      players = Root::Players::List.new(cat_player, bird_player)
      cat_player.players = players
      allow(cat_player).to receive(:pick_option).and_return(0)
      allow(cat_player).to receive(:be_shown_hand)

      card = Root::Cards::Improvements::Codebreakers.new
      cat_faction.improvements << card
      bird_faction.hand << Root::Cards::Base.new(suit: :fox)

      cat_faction.codebreakers

      expect(cat_player).to have_received(:be_shown_hand)
    end
  end

  describe '#do_with_birdsong_options' do
    it 'allows user to pick multiple options in daylight when available' do
      players = Root::Players::List.new(cat_player, bird_player)
      cat_player.players = players
      allow(cat_player).to receive(:pick_option).and_return(1, 0)

      card = Root::Cards::Improvements::StandAndDeliver.new
      cat_faction.improvements << card
      bird_faction.hand << Root::Cards::Base.new(suit: :fox)

      expect { cat_faction.birdsong }
        .to change(cat_faction, :hand_size)
        .by(1)
        .and change(bird_faction, :hand_size)
        .by(-1)
    end

    it 'can skip the extra options but must do the required ones' do
      players = Root::Players::List.new(cat_player, bird_player)
      cat_player.players = players
      allow(cat_player).to receive(:pick_option).and_return(0, 1)

      card = Root::Cards::Improvements::StandAndDeliver.new
      cat_faction.improvements << card
      bird_faction.hand << Root::Cards::Base.new(suit: :fox)

      expect { cat_faction.birdsong }
        .to change(cat_faction, :hand_size)
        .by(0)
        .and change(bird_faction, :hand_size)
        .by(0)
    end

    it 'can start using improvement then cancel' do
      players = Root::Players::List.new(cat_player, bird_player)
      cat_player.players = players
      # 1: select improvement
      # 1: cancel / :none
      # 0: pick wood
      # 1: finish /:none
      allow(cat_player).to receive(:pick_option).and_return(1, 1, 0, 1)

      card = Root::Cards::Improvements::StandAndDeliver.new
      cat_faction.improvements << card
      bird_faction.hand << Root::Cards::Base.new(suit: :fox)

      expect { cat_faction.birdsong }
        .to change(cat_faction, :hand_size)
        .by(0)
        .and change(bird_faction, :hand_size)
        .by(0)
    end
  end

  describe '#royal_claim' do
    it 'requires 4 matching craftable suits' do
      allow(cat_player).to receive(:pick_option).and_return(1, 0)

      card = Root::Cards::Improvements::RoyalClaim.new

      expect(cat_faction.royal_claim?).to be false

      cat_faction.improvements << card

      expect(cat_faction.royal_claim?).to be true

      cat_faction.place_meeple(clearings[:one])
      cat_faction.place_meeple(clearings[:two])
      cat_faction.place_meeple(clearings[:three])

      expect { cat_faction.birdsong }
        .to change(cat_faction, :victory_points)
        .by(3)
        .and change { cat_faction.improvements.count }
        .by(-1)
    end
  end

  describe '#other_attackable_factions' do
    context 'when in an coalition with them' do
      it 'removes that faction' do
        players = Root::Players::List.new(
          cat_faction,
          bird_faction,
          mouse_faction,
          racoon_faction
        )
        clearing = clearings[:one]
        cat_faction.place_meeple(clearing)
        cat_player.players = players
        bird_faction.place_meeple(clearing)
        bird_player.players = players
        mouse_faction.place_meeple(clearing)
        mouse_player.players = players
        racoon_faction.place_meeple(clearing)
        racoon_player.players = players

        racoon_faction.victory_points = :mice

        expect(cat_faction.other_attackable_factions(clearing))
          .to eq(%i[birds mice racoon])
        expect(bird_faction.other_attackable_factions(clearing))
          .to eq(%i[cats mice racoon])
        expect(racoon_faction.other_attackable_factions(clearing))
          .to eq(%i[cats birds])
        expect(mouse_faction.other_attackable_factions(clearing))
          .to eq(%i[cats birds])
      end
    end
  end
end
