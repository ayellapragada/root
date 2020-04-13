require 'io/console'

module Root
  # This is going to be handling input / output for different screens
  module Display
    # This is legit almost entirely just to GET the cursor location
    class Cursor
      def self.pos
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
    end
  end
end
