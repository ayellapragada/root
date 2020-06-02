# frozen_string_literal: true

module Root
  # Consolidates all choices for the front end
  class Choices
    def self.dry_run?
      !!$CHOICES
    end

    def call
      $CHOICES = []
    end
  end
end
