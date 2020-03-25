# frozen_string_literal: true

require_relative '../../pieces/token'
require_relative './catable'

module Root
  module Factions
    module Cats
      # Main starting token for the cat.
      # Allows for things like Field Hospital and etc.
      class Keep < Pieces::Token
        include Catable
      end
    end
  end
end
