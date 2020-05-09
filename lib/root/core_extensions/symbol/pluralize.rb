# frozen_string_literal: true

module Root
  module CoreExtensions
    module Symbol
      # Any monkey patches for Factions
      module Pluralize
        PLURAL_FORMS_EXCEPTIONS = {
          wood: :wood,
          keep: :keep,
          sympathy: :sympathy,
          fox: :foxes,
          mouse: :mice
        }.freeze

        def pluralize
          PLURAL_FORMS_EXCEPTIONS[self] || :"#{self}s"
        end
      end
    end
  end
end
