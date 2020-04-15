# frozen_string_literal: true

RSpec.describe Root::Players::List do
  describe '#initialize' do
    it 'sets players and current_player' do
      list = Root::Players::List.new(
        Root::Players::Human.for('Sneaky', :mice),
        Root::Players::Computer.for('Hal', :cats),
        Root::Players::Computer.for('Tron', :birds)
      )

      expect(list.player_count).to eq(3)
      expect(list.current_player.name).to be('Sneaky')
    end
  end

  describe '#rotate_current_player' do
    it 'rotates to the next and wraps around' do
      list = Root::Players::List.default_player_list

      expect(list.current_player.name).to be('Sneaky')
      list.rotate_current_player
      expect(list.current_player.name).to be('Hal')
      list.rotate_current_player
      expect(list.current_player.name).to be('Tron')
      list.rotate_current_player
      expect(list.current_player.name).to be('Ultron')
      list.rotate_current_player
      expect(list.current_player.name).to be('Sneaky')
    end
  end

  describe '#order_by_setup_priority' do
    it 'sorts by setup priority, not turn priority' do
      list = Root::Players::List.default_player_list
      ordered = list.order_by_setup_priority

      expect(ordered).to eq(
        [
          list.fetch_player(:cats),
          list.fetch_player(:birds),
          list.fetch_player(:mice),
          list.fetch_player(:racoon)
        ]
      )
    end
  end

  describe '#except_player' do
    it 'returns all other players' do
      list = Root::Players::List.default_player_list
      p1 = list.fetch_player(:cats)

      expect(list.except_player(p1)).to match_array(
        [
          list.fetch_player(:birds),
          list.fetch_player(:mice),
          list.fetch_player(:racoon)
        ]
      )
    end
  end
end
