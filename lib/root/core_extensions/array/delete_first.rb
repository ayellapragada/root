# frozen_string_literal: true

module Root
  module CoreExtensions
    module Array
      # Any monkey patches for Factions
      module DeleteFirst
        def delete_first(val)
          delete_at(index(val))
        end
      end
    end
  end
end
