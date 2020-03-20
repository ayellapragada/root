# frozen_string_literal: true

RSpec.describe Root::Players::List do
  describe '.initialize' do
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

  describe '.rotate_current_player' do
    it 'rotates to the next and wraps around' do
      list = Root::Players::List.new(
        Root::Players::Human.for('Sneaky', :mice),
        Root::Players::Computer.for('Hal', :cats),
        Root::Players::Computer.for('Tron', :birds)
      )

      expect(list.current_player.name).to be('Sneaky')
      list.rotate_current_player
      expect(list.current_player.name).to be('Hal')
      list.rotate_current_player
      expect(list.current_player.name).to be('Tron')
      list.rotate_current_player
      expect(list.current_player.name).to be('Sneaky')
    end
  end
end
