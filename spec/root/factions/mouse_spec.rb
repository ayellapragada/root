# frozen_string_literal: true

RSpec.describe Root::Factions::Mouse do
  describe '#handle_faction_token_setup' do
    it 'gives faction 10 meeples, 3 bases, and 10 sympathy' do
      _player, faction = build_player_and_faction(:mice)

      expect(faction.meeples.count).to eq(10)
      expect(faction.bases.count).to eq(3)
      expect(faction.sympathy.count).to eq(10)
      expect(faction.officers.count).to eq(0)
      expect(faction.supporters.count).to eq(0)
    end
  end

  describe '#setup' do
    it 'draws 3 supporters from deck' do
      player, faction = build_player_and_faction(:mice)

      expect { player.setup }.to change(faction.supporters, :count).by(3)
    end
  end

  describe '#special_info' do
    context 'when for current player' do
      it 'shows the number and types of supporters' do
        player, faction = build_player_and_faction(:mice)
        clearings = player.board.clearings

        faction.place_base(clearings[:one])
        faction.supporters << Root::Cards::Base.new(suit: :bunny)
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
              title: "Outrage | Guerilla Warfare | Martial Law\n0 Officers | No items",
              rows: [
                ['Supporters', 'Fox: 0', 'Bunny: 1', 'Mouse: 2', 'Bird: 1'],
                ['Bases', '(+1)', 'Bunny', 'Mouse', ' '],
                ['Sympathy', '(1) 0 1 1', '(2) 1 2 S', '(3) S S S S', ' ']
              ]
            }
          }
        )
      end
    end

    context 'when for other players' do
      it 'shows the number of supporters only' do
        player, faction = build_player_and_faction(:mice)
        clearings = player.board.clearings

        faction.supporters << Root::Cards::Base.new(suit: :bunny)
        faction.supporters << Root::Cards::Base.new(suit: :mouse)
        faction.supporters << Root::Cards::Base.new(suit: :mouse)
        faction.supporters << Root::Cards::Base.new(suit: :bird)

        expect(faction.special_info(false)).to eq(
          {
            board: {
              title: "Outrage | Guerilla Warfare | Martial Law\n4 Supporters | 0 Officers | No items",
              rows: [
                ['Bases', 'Fox', 'Bunny', 'Mouse'],
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
          player, faction = build_player_and_faction(:mice)
          cat_player, cat_faction = build_player_and_faction(:cats)
          allow(cat_player).to receive(:pick_option).and_return(0)
          players = Root::Players::List.new(player, cat_player)

          clearings = player.board.clearings
          cat_faction.hand << Root::Cards::Base.new(suit: :fox)
          cat_faction.place_meeple(clearings[:five])
          faction.place_sympathy(clearings[:one])

          expect { cat_faction.move(clearings[:five], players) }
            .to change(faction.supporters, :count)
            .by(1)
            .and change(cat_faction, :hand_size)
            .by(-1)
        end
      end

      context 'without matching card' do
        it 'lets faction draw to supporters' do
          player, faction = build_player_and_faction(:mice)
          cat_player, cat_faction = build_player_and_faction(:cats)
          allow(cat_player).to receive(:pick_option).and_return(0)
          players = Root::Players::List.new(player, cat_player)

          clearings = player.board.clearings
          cat_faction.place_meeple(clearings[:five])
          faction.place_sympathy(clearings[:one])

          expect { cat_faction.move(clearings[:five], players) }
            .to change(faction.supporters, :count)
            .by(1)
            .and change(faction.deck, :size)
            .by(-1)
        end
      end
    end

    context 'when other fation moves into clearing without sympathetic token' do
      it 'does nothing' do
        player, faction = build_player_and_faction(:mice)
        allow(player).to receive(:pick_option).and_return(0)
        cat_player, cat_faction = build_player_and_faction(:cats)
        allow(cat_player).to receive(:pick_option).and_return(0)
        players = Root::Players::List.new(player, cat_player)

        clearings = player.board.clearings
        cat_faction.hand << Root::Cards::Base.new(suit: :fox)
        cat_faction.place_meeple(clearings[:five])
        faction.place_meeple(clearings[:one])
        faction.place_meeple(clearings[:five])

        # This does nothing, just testing outrage doesn't trigger on self
        faction.move(clearings[:five], players)

        expect { cat_faction.move(clearings[:five], players) }
          .to change(faction.supporters, :count)
          .by(0)
          .and change(cat_faction, :hand_size)
          .by(0)
      end
    end

    context 'when other faction removes sympathy token' do
      it 'must give card' do
        player, faction = build_player_and_faction(:mice)
        cat_player, cats = build_player_and_faction(:cats)
        allow(cat_player).to receive(:pick_option).and_return(0)

        allow_any_instance_of(Root::Actions::Battle).
          to receive(:dice_roll).and_return(2, 1)

        clearings = player.board.clearings
        cats.hand << Root::Cards::Base.new(suit: :fox)
        cats.place_meeple(clearings[:one])
        faction.place_sympathy(clearings[:one])

        expect { cats.initiate_battle_with_faction(clearings[:one], faction) }
          .to change(faction.supporters, :count)
          .by(1)
          .and change(cats, :hand_size)
          .by(-1)
      end

      it 'does nothing if only meeples removed' do
        player, faction = build_player_and_faction(:mice)
        cat_player, cats = build_player_and_faction(:cats)
        allow(cat_player).to receive(:pick_option).and_return(0)

        allow_any_instance_of(Root::Actions::Battle).
          to receive(:dice_roll).and_return(1, 1)

        clearings = player.board.clearings
        cats.hand << Root::Cards::Base.new(suit: :fox)
        cats.place_meeple(clearings[:one])
        faction.place_meeple(clearings[:one])

        expect { faction.initiate_battle_with_faction(clearings[:one], cats) }
          .to change(faction.supporters, :count)
          .by(0)
          .and change(cats, :hand_size)
          .by(0)
      end
    end
  end

  describe '#guerilla warfare' do
    it 'does nothing if only meeples removed' do
      player, faction = build_player_and_faction(:mice)
      cat_player, cats = build_player_and_faction(:cats)

      allow(cat_player).to receive(:pick_option).and_return(0)
      allow_any_instance_of(Root::Actions::Battle).
        to receive(:dice_roll).and_return(2, 0)

      clearing = player.board.clearings[:one]
      cats.place_meeple(clearing)
      cats.place_meeple(clearing)
      cats.place_meeple(clearing)
      faction.place_meeple(clearing)
      faction.place_meeple(clearing)

      cats.initiate_battle_with_faction(clearing, faction)
      expect(clearing.meeples_of_type(:cats).count).to eq(1)
      expect(clearing.meeples_of_type(:mice).count).to eq(2)
    end
  end

  describe '#revolt_options' do
    it 'picks all unbuilt bases with 2 supporters and sympathy token' do
      player, faction = build_player_and_faction(:mice)
      clearings = player.board.clearings

      faction.place_base(clearings[:one])
      faction.place_sympathy(clearings[:one])
      faction.supporters << Root::Cards::Base.new(suit: :fox)
      faction.supporters << Root::Cards::Base.new(suit: :fox)

      faction.supporters << Root::Cards::Base.new(suit: :bunny)
      faction.supporters << Root::Cards::Base.new(suit: :bird)
      faction.place_sympathy(clearings[:five])
      faction.place_sympathy(clearings[:two])

      expect(faction.revolt_options).to eq([clearings[:five]])
    end
  end

  describe '#revolt' do
    it 'returns all other faction pieces back to owner' do
      player, faction = build_player_and_faction(:mice)
      allow(player).to receive(:pick_option).and_return(0)
      cat_player, cat_faction = build_player_and_faction(:cats)
      bird_player, bird_faction = build_player_and_faction(:birds)
      players = Root::Players::List.new(player, cat_player, bird_player)
      clearings = player.board.clearings

      cat_faction.place_wood(clearings[:one])
      bird_faction.place_roost(clearings[:one])
      cat_faction.place_meeple(clearings[:one])
      cat_faction.place_meeple(clearings[:one])
      bird_faction.place_meeple(clearings[:one])

      faction.supporters << Root::Cards::Base.new(suit: :fox)
      faction.supporters << Root::Cards::Base.new(suit: :bird)
      faction.place_sympathy(clearings[:one])
      faction.place_meeple(clearings[:one])

      expect { faction.revolt(players) }
        .to change { faction.victory_points }
        .by(2)
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
      player, faction = build_player_and_faction(:mice)
      allow(player).to receive(:pick_option).and_return(1)
      cat_player, cat_faction = build_player_and_faction(:cats)
      players = Root::Players::List.new(player, cat_player)
      clearings = player.board.clearings

      cat_faction.place_meeple(clearings[:one])

      faction.supporters << Root::Cards::Base.new(suit: :fox)
      faction.supporters << Root::Cards::Base.new(suit: :bird)
      faction.place_sympathy(clearings[:one])

      expect { faction.revolt(players) }.not_to change { clearings[:one] }
    end
  end

  describe '#spread_sympathy_options' do
    context 'when no sympathy is currently on the board' do
      it 'can be placed anywhere with the valid supporters' do
        player, faction = build_player_and_faction(:mice)
        clearings = player.board.clearings
        faction.supporters << Root::Cards::Base.new(suit: :fox)
        faction.supporters << Root::Cards::Base.new(suit: :bunny)

        expect(faction.spread_sympathy_options).to match_array([
          clearings[:one], clearings[:six], clearings[:eight], clearings[:twelve],
          clearings[:three], clearings[:four], clearings[:five], clearings[:ten]
        ])
      end
    end

    context 'when sympathy exists' do
      it 'must be placed adjacent with valid number of supporters' do
        player, faction = build_player_and_faction(:mice)
        clearings = player.board.clearings

        faction.supporters << Root::Cards::Base.new(suit: :fox)

        faction.place_sympathy(clearings[:five])
        expect(faction.spread_sympathy_options).to match_array([clearings[:one]])
      end

      it 'handles multiple adjacencies' do
        player, faction = build_player_and_faction(:mice)
        clearings = player.board.clearings

        faction.supporters << Root::Cards::Base.new(suit: :fox)
        faction.supporters << Root::Cards::Base.new(suit: :bunny)

        faction.place_sympathy(clearings[:five])
        faction.place_sympathy(clearings[:two])
        expect(faction.spread_sympathy_options)
          .to match_array([clearings[:one], clearings[:ten], clearings[:six]])
      end

      it 'must account for martial law' do
        player, faction = build_player_and_faction(:mice)
        _cat_player, cat_faction = build_player_and_faction(:cats)
        clearings = player.board.clearings

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
      player, faction = build_player_and_faction(:mice)
      allow(player).to receive(:pick_option).and_return(0)
      clearings = player.board.clearings

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
      player, faction = build_player_and_faction(:mice)
      allow(player).to receive(:pick_option).and_return(1)
      clearings = player.board.clearings

      faction.supporters << Root::Cards::Base.new(suit: :fox)
      faction.place_sympathy(clearings[:five])

      expect(faction.spread_sympathy_options).to eq([clearings[:one]])
      expect { faction.spread_sympathy }.not_to change { faction.sympathy }
    end
  end

  describe '#daylight_options' do
    it 'returns options' do
      _player, faction = build_player_and_faction(:mice)
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
      player, faction = build_player_and_faction(:mice)
      clearings = player.board.clearings

      faction.place_base(clearings[:one])

      expect(faction.built_base_suits).to eq([:fox])
    end
  end

  describe '#train_options' do
    it 'returns all suits of built bases' do
      player, faction = build_player_and_faction(:mice)
      clearings = player.board.clearings

      fox_card = Root::Cards::Base.new(suit: :fox)
      bunny_card = Root::Cards::Base.new(suit: :bunny)
      faction.hand << fox_card
      faction.hand << bunny_card

      expect(faction.can_train?).to be false
      faction.place_base(clearings[:one])

      expect(faction.train_options).to eq([fox_card])
      expect(faction.can_train?).to be true
    end

    it 'works with birds' do
      player, faction = build_player_and_faction(:mice)
      clearings = player.board.clearings

      bird_card = Root::Cards::Base.new(suit: :bird)
      faction.hand << bird_card
      faction.place_base(clearings[:one])

      expect(faction.train_options).to eq([bird_card])
    end

    it 'does not override everything with 1 bird' do
      _player, faction = build_player_and_faction(:mice)

      bird_card = Root::Cards::Base.new(suit: :bird)
      faction.hand << bird_card

      expect(faction.train_options).to eq([])
    end
  end

  describe '#mobilize' do
    it 'adds a card from hand to supporters' do
      player, faction = build_player_and_faction(:mice)
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
      player, faction = build_player_and_faction(:mice)
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
      player, faction = build_player_and_faction(:mice)
      clearings = player.board.clearings

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
      _player, faction = build_player_and_faction(:mice)
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
      player, faction = build_player_and_faction(:mice)
      clearings = player.board.clearings
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
      player, faction = build_player_and_faction(:mice)
      clearings = player.board.clearings

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
      _player, faction = build_player_and_faction(:mice)

      expect { faction.promote_officer }
        .to change { faction.meeples.count }
        .by(-1)
        .and change { faction.officers.count }
        .by(1)
    end
  end

  describe '#military_operations' do
    it 'allows as many actions as officers' do
      player, faction = build_player_and_faction(:mice)
      # Pick Recruit as an option
      allow(player).to receive(:pick_option).and_return(0)
      clearings = player.board.clearings
      players = Root::Players::List.new(player)

      faction.promote_officer
      faction.place_base(clearings[:one])

      expect { faction.military_operations(players) }
        .to change { clearings[:one].meeples_of_type(:mice).count }.by(1)
    end
  end

  describe '#recruit' do
    it 'places a warrior at a base' do
      player, faction = build_player_and_faction(:mice)
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
      player, faction = build_player_and_faction(:mice)
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
end
