require 'io/console'

module Root
  # This is going to be handling input / output for different screens
  module Display
    # This is legit almost entirely just to GET the cursor location
    class Cursor
      class << self
        # :nocov:
        def clear_previous_line
          move_up(2)
          clear_line
          move_up(2)
        end

        def hide_cursor
          puts "\e[?25l"
        end

        def clear_line
          puts "\e[K"
        end

        def move_up(num)
          puts "\e[#{num}A"
        end

        def show_cursor
          puts "\e[?25h"
        end

        def save_position
          puts "\e[s"
        end

        def restore_position
          puts "\e[u"
        end

        def move_to_top
          move_to_area(0, 0)
        end

        def move_to_area(row, col)
          puts "\e[#{row};#{col}H"
        end

        def move_forward(num)
          puts "\e[#{num}C"
        end
        # :nocov:
      end
    end
  end
end
