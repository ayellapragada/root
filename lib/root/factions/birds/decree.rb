# frozen_string_literal: true

module Root
  module Factions
    module Birds
      # Data Structure to contain Decree
      class Decree
        attr_reader :decree, :resolved

        def initialize
          @decree = { recruit: [], move: [], battle: [], build: [] }
          @resolved = { recruit: [], move: [], battle: [], build: [] }
        end

        def choices
          decree.keys
        end

        def [](key)
          decree[key]
        end

        def suits_in(key)
          self[key].map(&:suit)
        end

        def suits_in_decree
          decree.transform_values { |v| v.map(&:suit) }
        end

        def empty?
          decree.values.all?(&:empty?)
        end

        def size
          decree.values.map(&:size).sum
        end

        def resolved?
          decree.keys.all? { |action| resolved_action?(action) }
        end

        def resolved_action?(action)
          in_decree = decree[action].map(&:suit)

          handled_suits = in_decree.dup.delete_elements_in(resolved[action])
          left_over = resolved[action].dup.delete_elements_in(in_decree)

          handled_suits.length == left_over.length
        end

        def suits_needed(action)
          in_decree = decree[action].map(&:suit)

          in_decree.dup.delete_elements_in(resolved[action])
        end

        def clear_resolved
          resolved.each { |k, _| resolved[k] = [] }
        end

        def resolve_in(action, suit)
          resolved[action] << resolve_bird_in_decree(action, suit)
        end

        def resolve_bird_in_decree(action, suit)
          suits_needed(action).include?(suit) ? suit : :bird
        end

        def number_of_birds
          decree.values.flatten.count(&:bird?)
        end

        def all_cards_except_viziers
          decree.values.flatten.reject(&:vizier?)
        end

        def special_info
          rows = []
          suits = suits_in_decree
          until suits.values.all?(&:empty?)
            recruit_val = format_and_pop_card(:recruit, suits)
            move_val = format_and_pop_card(:move, suits)
            battle_val = format_and_pop_card(:battle, suits)
            build_val = format_and_pop_card(:build, suits)

            rows << [recruit_val, move_val, battle_val, build_val]
          end

          rows
        end

        def format_and_pop_card(key, dup_decree)
          suit = dup_decree[key].first
          count = dup_decree[key].count { |s| s == suit }
          dup_decree[key].delete(suit)
          formatted = suit.to_s.capitalize

          if count == 1
            formatted
          elsif count > 1
            "#{formatted} (#{count})"
          else
            ''
          end
        end
      end
    end
  end
end
