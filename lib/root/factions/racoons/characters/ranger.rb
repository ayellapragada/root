# frozen_string_literal: true

require_relative './character'

module Root
  module Factions
    module Racoons
      module Characters
        # Ranger Specific Logic
        class Ranger < Character
          STARTING_ITEMS = %i[boots torch crossbow sword].freeze
          POWER = :hideout

          def can_special?(*)
            torch? && !special_options.empty?
          end

          def special_options(*)
            f.damaged_items
          end

          def special(*)
            num_to_repair = 3

            if num_to_repair >= special_options.count
              special_options.each(&:repair)
              f.player.add_to_history(:r_c_hideout)
              return true
            end

            until num_to_repair <= 0
              f.player.choose(
                :r_item_repair,
                special_options,
                required: true,
                info: { num: num_to_repair },
                &:repair
              )
              num_to_repair -= 1
            end

            f.player.add_to_history(:r_c_hideout)
          end
        end
      end
    end
  end
end
