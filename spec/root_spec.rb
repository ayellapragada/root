# frozen_string_literal: true

RSpec.describe Root do
  it 'has a version number' do
    expect(Root::VERSION).not_to be nil
  end
end
