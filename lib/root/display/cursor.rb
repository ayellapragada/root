require 'io/console'

module Root
  # This is going to be handling input / output for different screens
  module Display
    # This is legit almost entirely just to GET the cursor location
    class Cursor
      class << self
        def pos
          res = ''
          $stdin.raw do |stdin|
            $stdout << "\e[6n"
            $stdout.flush
            # nocoving for terminal tbh
            # :nocov:
            while (c = stdin.getc) != 'R'
              res << c if c
            end
            # :nocov:
          end
          m = res.match /(?<row>\d+);(?<column>\d+)/
          { row: Integer(m[:row]), column: Integer(m[:column]) }
        end

        # :nocov:
        def clear_previous_line
          move_two_up
          clear_line
          move_two_up
        end

        def hide_cursor
          puts "\e[?25l"
        end

        def clear_line
          puts "\e[0K"
        end

        def move_two_up
          puts "\e[2A"
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
          puts "\e[0;0H"
        end
        # :nocov:
      end
    end
  end
end
