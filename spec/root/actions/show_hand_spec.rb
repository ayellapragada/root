# frozen_string_literal: true

RSpec.describe Root::Actions::ShowHand do
  let(:cat_player) { Root::Players::Computer.for('Cat', :cats) }
  let(:cat_faction) { cat_player.faction }
  let(:mouse_player) { Root::Players::Human.for('Sneak', :mice) }
  let(:mouse_faction) { mouse_player.faction }

  it 'shows hand to other player' do
    allow_any_instance_of(Root::Display::Menu).to receive(:display)

    cat_faction.hand << Root::Cards::Base.new(suit: :fox)
    cat_faction.hand << Root::Cards::Base.new(suit: :bird)

    cat_faction.show_hand(mouse_faction)
  end
end
