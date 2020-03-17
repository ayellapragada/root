# frozen_string_literal: true

RSpec.describe ForestCreatures::Board do
  it 'is all connected' do
    expect(described_class.new.wah).to be true
  end
end
