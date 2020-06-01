# frozen_string_literal: true

module Root
  # Consolidates all choices for the front end
  class Choices
    def call
      $CHOICES = []
    end
  end
end
