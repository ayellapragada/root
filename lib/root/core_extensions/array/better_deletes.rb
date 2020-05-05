# frozen_string_literal: true

module Root
  module CoreExtensions
    module Array
      # Any monkey patches for Factions
      module BetterDeletes
        def delete_first(val)
          delete_at(index(val))
        end

        def delete_elements_in(values)
          counts = values.each_with_object(Hash.new(0)) { |v, h| h[v] += 1; }
          reject { |e| counts[e] -= 1 unless counts[e].zero? }
        end
      end
    end
  end
end
