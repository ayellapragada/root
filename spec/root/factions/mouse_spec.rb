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

        faction.place_base(:fox, clearings[:one])
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
              headings: [' ', 'Fox', 'Bunny', 'Mouse', 'Bird'],
              rows: [
                %w[Bases (+1) B B -],
                %w[Supporters 0 1 2 1]
              ]
            },
            sympathy: {
              headings: ['   1', '   2', '   3'],
              rows: [
                ['0 1 1', '1 2 S', 'S S S S']
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

        faction.place_base(:fox, clearings[:one])
        faction.supporters << Root::Cards::Base.new(suit: :bunny)
        faction.supporters << Root::Cards::Base.new(suit: :mouse)
        faction.supporters << Root::Cards::Base.new(suit: :mouse)
        faction.supporters << Root::Cards::Base.new(suit: :bird)

        expect(faction.special_info(false)).to eq(
          {
            board: {
              title: "Outrage | Guerilla Warfare | Martial Law\n0 Officers | No items\n4 Supporters",
              headings: [' ', 'Fox', 'Bunny', 'Mouse', 'Bird'],
              rows: [
                %w[Bases (+1) B B -]
              ]
            },
            sympathy: {
              headings: ['   1', '   2', '   3'],
              rows: [
                ['S S S', 'S S S', 'S S S S']
              ]
            }
          }
        )
      end
    end
  end
end
