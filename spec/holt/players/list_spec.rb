# frozen_string_literal: true

RSpec.describe Holt::Players::List do
  describe '.initialize' do
    it 'sets players and current_player' do
      list = Holt::Players::List.new(
        Holt::Players::Human.for('Sneaky', :mice),
        Holt::Players::Computer.for('Hal', :cats),
        Holt::Players::Computer.for('Tron', :birds)
      )

      expect(list.player_count).to eq(3)
      expect(list.current_player.name).to be('Sneaky')
    end
  end

  describe '.rotate_current_player' do
    it 'rotates to the next and wraps around' do
      list = Holt::Players::List.new(
        Holt::Players::Human.for('Sneaky', :mice),
        Holt::Players::Computer.for('Hal', :cats),
        Holt::Players::Computer.for('Tron', :birds)
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
