# frozen_string_literal: true

RSpec.describe Root::Factions::Birds::Decree do
  describe '#resolved?' do
    it 'returns true when entire decree has been resolved' do
      decree = described_class.new

      decree[:recruit] << Root::Cards::Base.new(suit: :fox)
      decree[:recruit] << Root::Cards::Base.new(suit: :rabbit)
      decree[:recruit] << Root::Cards::Base.new(suit: :bird)

      decree[:move] << Root::Cards::Base.new(suit: :bird)
      decree[:move] << Root::Cards::Base.new(suit: :bird)

      decree[:battle] << Root::Cards::Base.new(suit: :mouse)
      decree[:battle] << Root::Cards::Base.new(suit: :mouse)
      decree[:battle] << Root::Cards::Base.new(suit: :fox)

      decree[:build] << Root::Cards::Base.new(suit: :rabbit)
      decree[:build] << Root::Cards::Base.new(suit: :fox)

      decree.resolve_in(:recruit, :fox)
      decree.resolve_in(:recruit, :mouse)
      decree.resolve_in(:recruit, :rabbit)

      decree.resolve_in(:move, :rabbit)
      decree.resolve_in(:move, :fox)

      decree.resolve_in(:battle, :mouse)
      decree.resolve_in(:battle, :mouse)
      decree.resolve_in(:battle, :fox)

      decree.resolve_in(:build, :rabbit)
      expect(decree.resolved?).to be false

      decree.resolve_in(:build, :fox)
      expect(decree.resolved?).to be true
    end
  end

  describe '#suits_needed' do
    it 'brings returns all remaining needed suits ' do
      decree = described_class.new
      decree[:recruit] << Root::Cards::Base.new(suit: :fox)
      decree[:recruit] << Root::Cards::Base.new(suit: :rabbit)
      decree[:recruit] << Root::Cards::Base.new(suit: :bird)

      decree.resolve_in(:recruit, :fox)
      expect(decree.suits_needed(:recruit)).to eq(%i[rabbit bird])

      decree.resolve_in(:recruit, :fox)
      expect(decree.suits_needed(:recruit)).to eq([:rabbit])
    end
  end
end
