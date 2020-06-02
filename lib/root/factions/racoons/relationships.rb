# frozen_string_literal: true

module Root
  module Factions
    module Racoons
      # This will just make it easier to handle relationships
      class Relationships
        attr_reader :relationships, :vp_to_gain

        DISPLAY = {
          0 => '0',
          1 => '1',
          2 => '2',
          3 => 'A',
          9 => 'H'
        }.freeze

        def initialize(players)
          @relationships = {}
          players.each do |p|
            relationships[p.faction_symbol] = { status: 0, num_aided: 0 }
          end
          @vp_to_gain = 0
        end

        def aid_once(fac)
          @vp_to_gain = 0
          self[fac][:num_aided] += 1

          improve_status(fac) if able_to_improve_status?(fac)
        end

        def make_hostile(fac)
          self[fac][:status] = 9
        end

        def hostile?(fac)
          self[fac][:status] == 9
        end

        def allied?(fac)
          self[fac][:status] == 3
        end

        def reset_turn_counters
          relationships.each { |_, v| v[:num_aided] = 0 }
        end

        # This is making me hesitant, maybe just something to revisit
        def [](val)
          relationships[val] || {}
        end

        def all_neutral?
          relationships.values.all? { |i| i[:status].zero? }
        end

        def count
          @relationships.keys.count
        end

        private

        def able_to_improve_status?(fac)
          not_hostile?(fac) &&
            aided_enough_in_one_turn?(fac) &&
            another_level_for_status?(fac)
        end

        def not_hostile?(fac)
          !hostile?(fac)
        end

        def aided_enough_in_one_turn?(fac)
          self[fac][:num_aided] > self[fac][:status]
        end

        def another_level_for_status?(fac)
          self[fac][:status] < 3
        end

        def improve_status(fac)
          self[fac][:status] += 1
          @vp_to_gain = self[fac][:status]
          self[fac][:num_aided] = 0
        end
      end
    end
  end
end
