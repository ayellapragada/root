# frozen_string_literal: true

require 'root/version'
require 'root/game'

require 'root/boards/woodlands'
require 'root/boards/woodlands_generator'

require 'root/cards/base'
require 'root/cards/item'

require 'root/decks/starter'

require 'root/display/terminal'
require 'root/display/woodlands_terminal'

require 'root/factions/bird'
require 'root/factions/cat'
require 'root/factions/mouse'
require 'root/factions/vagabond'

require 'root/factions/cats/catable'
require 'root/factions/cats/keep'
require 'root/factions/cats/recruiter'
require 'root/factions/cats/sawmill'
require 'root/factions/cats/wood'
require 'root/factions/cats/workshop'

require 'root/factions/birds/birdable'
require 'root/factions/birds/decree'
require 'root/factions/birds/leader'
require 'root/factions/birds/roost'

require 'root/factions/mice/miceable'
require 'root/factions/mice/base'
require 'root/factions/mice/sympathy'

require 'root/grid/clearing'
require 'root/grid/empty_slot'
require 'root/grid/ruin'

require 'root/players/computer'
require 'root/players/human'
require 'root/players/list'

require 'root/pieces/building'
require 'root/pieces/token'
require 'root/pieces/meeple'

module Root
end
