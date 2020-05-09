# frozen_string_literal: true

RSpec.describe Root::Factions::Mouse do
  let(:player) { Root::Players::Computer.for('Sneak', :mice) }
  let(:faction) { player.faction }
  let(:board) { player.board }
  let(:clearings) { board.clearings }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }
  let(:cat_player) { Root::Players::Computer.for('Cat', :cats) }
  let(:cat_faction) { cat_player.faction }

  describe '#handle_faction_token_setup' do
    it 'gives faction 10 meeples, 3 bases, and 10 sympathy' do
      expect(faction.meeples.count).to eq(10)
      expect(faction.bases.count).to eq(3)
      expect(faction.sympathy.count).to eq(10)
      expect(faction.officers.count).to eq(0)
      expect(faction.supporters.count).to eq(0)
    end
  end

  describe '#setup' do
    it 'draws 3 supporters from deck' do
      expect { player.setup }.to change(faction.supporters, :count).by(3)
    end
  end

  describe '#special_info' do
    context 'when for current player' do
      it 'shows the number and types of supporters' do
        faction.place_base(clearings[:one])
        faction.supporters << Root::Cards::Base.new(suit: :rabbit)
        faction.supporters << Root::Cards::Base.new(suit: :mouse)
        faction.supporters << Root::Cards::Base.new(suit: :mouse)
        faction.supporters << Root::Cards::Base.new(suit: :bird)
        faction.place_sympathy(clearings[:one])
        faction.place_sympathy(clearings[:two])
        faction.place_sympathy(clearings[:three])
        faction.place_sympathy(clearings[:four])
        faction.place_sympathy(clearings[:five])

        expect(faction.special_info(true)).to eq(
          {
            board: {
              title: "Outrage | Guerilla Warfare | Martial Law\n0 Officers \nNo Items",
              rows: [
                ['Bird (1)', 'Fox (0)', 'Rabbit (1)', 'Mouse (2)'],
                ['Bases', '(+1)', 'Rabbit', 'Mouse'],
                ['Sympathy', '(1) 0 1 1', '(2) 1 2 S', '(3) S S S S']
              ]
            }
          }
        )
      end
    end

    context 'when for other players' do
      it 'shows the number of supporters only' do
        faction.supporters << Root::Cards::Base.new(suit: :rabbit)
        faction.supporters << Root::Cards::Base.new(suit: :mouse)
        faction.supporters << Root::Cards::Base.new(suit: :mouse)
        faction.supporters << Root::Cards::Base.new(suit: :bird)

        expect(faction.special_info(false)).to eq(
          {
            board: {
              title: "Outrage | Guerilla Warfare | Martial Law\n4 Supporters | 0 Officers \nNo Items",
              rows: [
                ['Bases', 'Fox', 'Rabbit', 'Mouse'],
                ['Sympathy', '(1) S S S', '(2) S S S', '(3) S S S S']
              ]
            }
          }
        )
      end
    end
  end

  describe '#outrage' do
    context 'when other faction moves into clearing with sympathy token' do
      context 'with matching card in hand' do
        it 'must give card' do
          allow(cat_player).to receive(:pick_option).and_return(0)
          players = Root::Players::List.new(player, cat_player)
          cat_player.players = players

          clearings = player.board.clearings
          cat_faction.hand << Root::Cards::Base.new(suit: :fox)
          cat_faction.place_meeple(clearings[:five])
          faction.place_sympathy(clearings[:one])

          expect { cat_faction.move(clearings[:five]) }
            .to change(faction.supporters, :count)
            .by(1)
            .and change(cat_faction, :hand_size)
            .by(-1)
        end
      end

      context 'without matching card' do
        it 'lets faction draw to supporters' do
          allow(cat_player).to receive(:pick_option).and_return(0)
          players = Root::Players::List.new(player, cat_player)
          cat_player.players = players

          clearings = player.board.clearings
          cat_faction.place_meeple(clearings[:five])
          faction.place_sympathy(clearings[:one])

          expect { cat_faction.move(clearings[:five]) }
            .to change(faction.supporters, :count)
            .by(1)
            .and change(faction.deck, :size)
            .by(-1)
        end
      end
    end

    context 'when other fation moves into clearing without sympathetic token' do
      it 'does nothing' do
        allow(player).to receive(:pick_option).and_return(0)
        allow(cat_player).to receive(:pick_option).and_return(0)
        players = Root::Players::List.new(player, cat_player)
        player.players = players
        cat_player.players = players

        clearings = player.board.clearings
        cat_faction.hand << Root::Cards::Base.new(suit: :fox)
        cat_faction.place_meeple(clearings[:five])
        faction.place_meeple(clearings[:one])
        faction.place_meeple(clearings[:five])

        # This does nothing, just testing outrage doesn't trigger on self
        faction.move(clearings[:five])

        expect { cat_faction.move(clearings[:five]) }
          .to change(faction.supporters, :count)
          .by(0)
          .and change(cat_faction, :hand_size)
          .by(0)
      end
    end

    context 'when other faction removes sympathy token' do
      it 'must give card' do
        allow(cat_player).to receive(:pick_option).and_return(0)

        allow_any_instance_of(Root::Actions::Battle).
          to receive(:dice_roll).and_return(2, 1)

        clearings = player.board.clearings
        cat_faction.hand << Root::Cards::Base.new(suit: :fox)
        cat_faction.place_meeple(clearings[:one])
        faction.place_sympathy(clearings[:one])

        expect { cat_faction.initiate_battle_with_faction(clearings[:one], faction) }
          .to change(faction.supporters, :count)
          .by(1)
          .and change(cat_faction, :hand_size)
          .by(-1)
      end

      it 'does nothing if only meeples removed' do
        allow(cat_player).to receive(:pick_option).and_return(0)

        allow_any_instance_of(Root::Actions::Battle).
          to receive(:dice_roll).and_return(1, 1)

        clearings = player.board.clearings
        cat_faction.hand << Root::Cards::Base.new(suit: :fox)
        cat_faction.place_meeple(clearings[:one])
        faction.place_meeple(clearings[:one])

        expect { faction.initiate_battle_with_faction(clearings[:one], cat_faction) }
          .to change(faction.supporters, :count)
          .by(0)
          .and change(cat_faction, :hand_size)
          .by(0)
      end
    end
  end

  describe '#guerilla warfare' do
    it 'gives defender the higher die roll' do
      allow(cat_player).to receive(:pick_option).and_return(0)
      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(2, 0)

      clearing = player.board.clearings[:one]
      cat_faction.place_meeple(clearing)
      cat_faction.place_meeple(clearing)
      cat_faction.place_meeple(clearing)

      faction.place_meeple(clearing)
      faction.place_meeple(clearing)

      cat_faction.initiate_battle_with_faction(clearing, faction)
      expect(clearing.meeples_of_type(:cats).count).to eq(1)
      expect(clearing.meeples_of_type(:mice).count).to eq(2)
    end
  end

  describe '#add_to_supporters' do
    context 'with no bases built' do
      it 'can only have up to 5 supporters at once' do
        4.times { faction.supporters << Root::Cards::Base.new(suit: :bird) }

        card1 = Root::Cards::Base.new(suit: :fox)
        card2 = Root::Cards::Base.new(suit: :fox)

        expect { faction.add_to_supporters([card1, card2]) }
          .to change { faction.supporters.count }
          .by(1)
          .and change { faction.deck.discard.count }
          .by(1)
      end
    end

    context 'with any bases built' do
      it 'can have any number of supporters' do
        faction.place_base(clearings[:one])

        4.times { faction.supporters << Root::Cards::Base.new(suit: :bird) }

        card1 = Root::Cards::Base.new(suit: :fox)
        card2 = Root::Cards::Base.new(suit: :fox)

        expect { faction.add_to_supporters([card1, card2]) }
          .to change { faction.supporters.count }
          .by(2)
          .and change { faction.deck.discard.count }
          .by(0)
      end
    end
  end

  describe '#revolt_options' do
    it 'picks all unbuilt bases with 2 supporters and sympathy token' do
      faction.place_base(clearings[:one])
      faction.place_sympathy(clearings[:one])
      faction.supporters << Root::Cards::Base.new(suit: :fox)
      faction.supporters << Root::Cards::Base.new(suit: :fox)

      faction.supporters << Root::Cards::Base.new(suit: :rabbit)
      faction.supporters << Root::Cards::Base.new(suit: :bird)
      faction.place_sympathy(clearings[:five])
      faction.place_sympathy(clearings[:two])

      expect(faction.revolt_options).to eq([clearings[:five]])
    end
  end

  describe '#revolt' do
    it 'returns all other faction pieces back to owner' do
      allow(player).to receive(:pick_option).and_return(0)
      players = Root::Players::List.new(player, cat_player, bird_player)
      player.players = players

      cat_faction.place_wood(clearings[:one])
      bird_faction.place_roost(clearings[:one])
      cat_faction.place_meeple(clearings[:one])
      cat_faction.place_meeple(clearings[:one])
      bird_faction.place_meeple(clearings[:one])

      faction.supporters << Root::Cards::Base.new(suit: :fox)
      faction.supporters << Root::Cards::Base.new(suit: :bird)
      faction.place_sympathy(clearings[:one])
      faction.place_meeple(clearings[:one])

      expect { faction.revolt }
        .to change { faction.victory_points }
        .by(2)
        .and change { faction.officers.count }
        .by(1)
        .and change { faction.usable_supporters(:fox).count }
        .by(-2)
        .and change { clearings[:one].meeples_of_type(:mice).count }
        .by(1)
        .and change { clearings[:one].meeples_of_type(:cats).count }
        .by(-2)
        .and change { clearings[:one].meeples_of_type(:birds).count }
        .by(-1)
        .and change { clearings[:one].meeples_of_type(:cats).count }
        .by(-2)
        .and change { clearings[:one].meeples_of_type(:birds).count }
        .by(-1)
      expect(clearings[:one].buildings_of_type(:base).count).to eq(1)
    end

    it 'does not have to revolt' do
      allow(player).to receive(:pick_option).and_return(1)
      clearings = player.board.clearings

      cat_faction.place_meeple(clearings[:one])

      faction.supporters << Root::Cards::Base.new(suit: :fox)
      faction.supporters << Root::Cards::Base.new(suit: :bird)
      faction.place_sympathy(clearings[:one])

      expect { faction.revolt }.not_to change { clearings[:one] }
    end

    context 'when no more meeples' do
      it 'does not recruit a meeple' do
        allow(player).to receive(:pick_option).and_return(0)
        10.times { faction.place_meeple(clearings[:one]) }
        faction.place_sympathy(clearings[:two])

        faction.supporters << Root::Cards::Base.new(suit: :mouse)
        faction.supporters << Root::Cards::Base.new(suit: :mouse)

        expect { faction.revolt }
          .to change { faction.officers.count }
          .by(0)
      end
    end
  end

  describe '#spread_sympathy_options' do
    context 'when no sympathy is currently on the board' do
      it 'can be placed anywhere with the valid supporters' do
        faction.supporters << Root::Cards::Base.new(suit: :fox)
        faction.supporters << Root::Cards::Base.new(suit: :rabbit)

        expect(faction.spread_sympathy_options).to match_array([
          clearings[:one], clearings[:six], clearings[:eight], clearings[:twelve],
          clearings[:three], clearings[:four], clearings[:five], clearings[:ten]
        ])
      end
    end

    context 'when sympathy exists' do
      it 'must be placed adjacent with valid number of supporters' do
        faction.supporters << Root::Cards::Base.new(suit: :fox)

        faction.place_sympathy(clearings[:five])
        expect(faction.spread_sympathy_options).to match_array([clearings[:one]])
      end

      it 'handles multiple adjacencies' do
        clearings = player.board.clearings

        faction.supporters << Root::Cards::Base.new(suit: :fox)
        faction.supporters << Root::Cards::Base.new(suit: :rabbit)

        faction.place_sympathy(clearings[:five])
        faction.place_sympathy(clearings[:two])
        expect(faction.spread_sympathy_options)
          .to match_array([clearings[:one], clearings[:ten], clearings[:six]])
      end

      it 'must account for martial law' do
        faction.supporters << Root::Cards::Base.new(suit: :fox)
        faction.supporters << Root::Cards::Base.new(suit: :mouse)
        faction.supporters << Root::Cards::Base.new(suit: :mouse)

        3.times { cat_faction.place_meeple(clearings[:one]) }
        faction.place_sympathy(clearings[:five])
        expect(faction.spread_sympathy_options).to match_array([clearings[:two]])
      end
    end
  end

  describe '#spread_sympathy' do
    it 'places a sympathy token' do
      allow(player).to receive(:pick_option).and_return(0)

      faction.supporters << Root::Cards::Base.new(suit: :fox)
      faction.place_sympathy(clearings[:five])

      expect(faction.spread_sympathy_options).to eq([clearings[:one]])
      expect { faction.spread_sympathy }
        .to change { faction.sympathy.count }
        .by(-1)
        .and change { faction.victory_points }
        .by(1)
    end

    it 'does not have to spread sympathy' do
      allow(player).to receive(:pick_option).and_return(1)

      faction.supporters << Root::Cards::Base.new(suit: :fox)
      faction.place_sympathy(clearings[:five])

      expect(faction.spread_sympathy_options).to eq([clearings[:one]])
      expect { faction.spread_sympathy }.not_to change { faction.sympathy }
    end
  end

  describe '#daylight_options' do
    it 'returns options' do
      allow(faction).to receive(:can_craft?).and_return(true)
      allow(faction).to receive(:can_mobilize?).and_return(false)
      allow(faction).to receive(:can_train?).and_return(true)

      expect(faction.daylight_options).to match_array(
        %i[craft train]
      )
    end
  end

  describe '#built_base_suits' do
    it 'returns all suits of built bases' do
      faction.place_base(clearings[:one])

      expect(faction.built_base_suits).to eq([:fox])
    end
  end

  describe '#train_options' do
    it 'returns all suits of built bases' do
      fox_card = Root::Cards::Base.new(suit: :fox)
      rabbit_card = Root::Cards::Base.new(suit: :rabbit)
      faction.hand << fox_card
      faction.hand << rabbit_card

      expect(faction.can_train?).to be false
      faction.place_base(clearings[:one])

      expect(faction.train_options).to eq([fox_card])
      expect(faction.can_train?).to be true
    end

    it 'works with birds' do
      bird_card = Root::Cards::Base.new(suit: :bird)
      faction.hand << bird_card
      faction.place_base(clearings[:one])

      expect(faction.train_options).to eq([bird_card])
    end

    it 'does not override everything with 1 bird' do
      bird_card = Root::Cards::Base.new(suit: :bird)
      faction.hand << bird_card

      expect(faction.train_options).to eq([])
    end
  end

  describe '#mobilize' do
    it 'adds a card from hand to supporters' do
      allow(player).to receive(:pick_option).and_return(0)

      faction.hand << Root::Cards::Base.new(suit: :fox)
      expect { faction.mobilize }
        .to change { faction.usable_supporters(:fox).count }
        .by(1)
        .and change { faction.hand_size }
        .by(-1)
    end
  end

  describe '#train' do
    it 'adds a card from hand to supporters' do
      allow(player).to receive(:pick_option).and_return(0)

      faction.hand << Root::Cards::Base.new(suit: :fox)
      faction.place_base(player.board.clearings[:one])
      expect { faction.train }
        .to change { faction.officers.count }
        .by(1)
        .and change { faction.hand_size }
        .by(-1)
        .and change { faction.meeples.count }
        .by(-1)
    end
  end

  describe '#can_train?' do
    it 'can train with a base and meeples' do
      faction.hand << Root::Cards::Base.new(suit: :fox)
      expect(faction.can_train?).to be false

      faction.place_base(clearings[:one])
      expect(faction.can_train?).to be true

      10.times { faction.place_meeple(clearings[:one]) }
      expect(faction.can_train?).to be false
    end
  end

  describe '#evening_options' do
    it 'returns options' do
      allow(faction).to receive(:can_move?).and_return(true)
      allow(faction).to receive(:can_recruit?).and_return(true)
      allow(faction).to receive(:can_battle?).and_return(true)
      allow(faction).to receive(:can_organize?).and_return(true)

      expect(faction.evening_options).to match_array(
        %i[move recruit battle organize]
      )
    end
  end

  describe '#recruit_options' do
    it 'returns places where faction has a base' do
      expect(faction.can_recruit?).to be false

      faction.place_base(clearings[:one])

      expect(faction.can_recruit?).to be true
      expect(faction.recruit_options).to eq([clearings[:one]])

      10.times { faction.place_meeple(clearings[:one]) }

      expect(faction.can_recruit?).to be false
    end
  end

  describe '#organize_options' do
    it 'returns places where a faction could organize' do
      expect(faction.can_organize?).to be false

      faction.place_meeple(clearings[:one])

      expect(faction.organize_options).to match_array([clearings[:one]])
      expect(faction.can_organize?).to be true

      faction.place_sympathy(clearings[:one])

      expect(faction.can_organize?).to be false
    end
  end

  describe '#promote_officer' do
    it 'makes one meeple an officer' do
      expect { faction.promote_officer }
        .to change { faction.meeples.count }
        .by(-1)
        .and change { faction.officers.count }
        .by(1)
    end

    context 'without meeples' do
      it 'does not convert a meeple into an officer' do
        10.times { faction.place_meeple(clearings[:one]) }

        expect { faction.promote_officer }
          .to change { faction.meeples.count }
          .by(0)
          .and change { faction.officers.count }
          .by(0)
      end
    end
  end

  describe '#military_operations' do
    it 'allows as many actions as officers' do
      # Pick Recruit as an option
      allow(player).to receive(:pick_option).and_return(0)
      clearings = player.board.clearings

      faction.promote_officer
      faction.place_base(clearings[:one])

      expect { faction.military_operations }
        .to change { clearings[:one].meeples_of_type(:mice).count }.by(1)
    end
  end

  describe '#recruit' do
    it 'places a warrior at a base' do
      allow(player).to receive(:pick_option).and_return(0)
      clearings = player.board.clearings

      faction.place_base(clearings[:one])
      faction.place_base(clearings[:five])

      expect { faction.recruit }
        .to change { clearings[:one].meeples_of_type(:mice).count }
        .by(1)
        .and change { faction.meeples.count }
        .by(-1)
    end
  end

  describe '#organize' do
    it 'replaces a warrior with a sympathy token' do
      allow(player).to receive(:pick_option).and_return(0)
      clearings = player.board.clearings

      faction.place_meeple(clearings[:one])
      expect { faction.organize }
        .to change { clearings[:one].meeples_of_type(:mice).count }
        .by(-1)
        .and change { clearings[:one].sympathetic? }
        .from(false).to(true)
        .and change { faction.meeples.count }
        .by(1)
    end
  end

  describe '#base_removed' do
    it 'discard all supporter of suit + birds, and half officers rounded up' do
      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(1, 0)

      faction.supporters << Root::Cards::Base.new(suit: :fox)
      faction.supporters << Root::Cards::Base.new(suit: :bird)
      cat_faction.place_meeple(clearings[:one])
      faction.place_base(clearings[:one])
      faction.place_base(clearings[:five])
      5.times { faction.promote_officer }

      expect { cat_faction.initiate_battle_with_faction(clearings[:one], faction) }
        .to change { faction.usable_supporters(:fox).count }
        .by(-2)
        .and change { faction.officers.count }
        .by(-3)
        .and change { faction.meeples.count }
        .by(3)
        .and change { faction.deck.discard.count }
        .by(2)
    end

    it 'if no more remaining bases, max 5 supporters' do
      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(1, 0)

      cat_faction.place_meeple(clearings[:one])
      faction.place_base(clearings[:one])

      6.times { faction.supporters << Root::Cards::Base.new(suit: :rabbit) }

      expect { cat_faction.initiate_battle_with_faction(clearings[:one], faction) }
        .to change { faction.usable_supporters(:rabbit).count }
        .by(-1)
        .and change { faction.deck.discard.count }
        .by(1)
    end
  end

  describe '#skip_outrage_for?' do
    it { expect(faction.skip_outrage_for?(:racoon)).to be true }
    it { expect(faction.skip_outrage_for?(:mice)).to be true }
  end
end
