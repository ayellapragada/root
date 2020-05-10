# frozen_string_literal: true

RSpec.describe Root::Cards::Dominance do
  let(:player) { Root::Players::Computer.for('Sneak', :mice) }
  let(:faction) { player.faction }
  let(:board) { player.board }
  let(:clearings) { board.clearings }
  let(:bird_player) { Root::Players::Computer.for('Bird', :birds) }
  let(:bird_faction) { bird_player.faction }
  let(:cat_player) { Root::Players::Computer.for('Cat', :cats) }
  let(:cat_faction) { cat_player.faction }
  let(:racoon_player) { Root::Players::Computer.for('Racoon', :racoon) }
  let(:racoon_faction) { racoon_player.faction }

  describe '#info' do
    it 'is hopefully helpful' do
      card = Root::Cards::Dominance.new(suit: :fox)
      expect(card.name).to eq('Dominance')
      expect(card.body).to eq('Rule 3 clearings of fox suit')
    end
  end

  describe '#faction_craft' do
    it 'removes all enemy pieces in all clearings of its suit' do
    end
  end
end
