# frozen_string_literal: true

RSpec.describe Root::Grid::Ruin do
  describe '.initialize' do
  end

  describe '.is_keep?' do
    it { expect(described_class.new.is_keep?).to be false }
  end
end
