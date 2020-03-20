# frozen_string_literal: true

require 'root/version'
require 'root/game'

require 'root/boards/woodlands'
require 'root/boards/woodlands_generator'

require 'root/cards/base'
require 'root/cards/item'

require 'root/decks/starter'

require 'root/factions/bird'
require 'root/factions/cat'
require 'root/factions/mouse'
require 'root/factions/vagabond'

require 'root/factions/pieces/cat/keep'

require 'root/grid/clearing'
require 'root/grid/ruin'

require 'root/players/computer'
require 'root/players/human'
require 'root/players/list'

module Root
  class Error < StandardError; end
  # Your code goes here...
end
