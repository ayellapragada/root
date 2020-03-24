# frozen_string_literal: true
# rubocop:disable all

# Color list
# ANSI colors
# black, red, green, yellow, blue, magenta, cyan, white

# X11 colors
# aliceblue, antiquewhite, aqua, aquamarine, azure, beige, bisque,
# blanchedalmond, blueviolet, brown, burlywood, cadetblue, chartreuse,
# chocolate, coral, cornflower, cornsilk, crimson, darkblue , darkcyan,
# darkgoldenrod, darkgray, darkgreen, darkkhaki, darkmagenta, darkolivegreen,
# darkorange, darkorchid, darkred, darksalmon, darkseagreen, darkslateblue,
# darkslategray, darkturquoise, darkviolet, deeppink, deepskyblue, dimgray,
# dodgerblue, firebrick, floralwhite, forestgreen, fuchsia, gainsboro,
# ghostwhite, gold, goldenrod, gray, greenyellow, honeydew, hotpink,
# indianred, indigo, ivory, khaki, lavender, lavenderblush, lawngreen,
# lemonchiffon, lightblue, lightcoral, lightcyan, lightgoldenrod, lightgray,
# lightgreen, lightpink, lightsalmon, lightseagreen, lightskyblue,
# lightslategray, lightsteelblue, lightyellow, lime, limegreen, linen, maroon,
# mediumaquamarine, mediumblue, mediumorchid, mediumpurple, mediumseagreen,
# mediumslateblue, mediumspringgreen, mediumturquoise, mediumvioletred,
# midnightblue, mintcream, mistyrose, moccasin, navajowhite, navyblue, oldlace,
# olive, olivedrab, orange, orangered, orchid, palegoldenrod, palegreen,
# paleturquoise, palevioletred, papayawhip, peachpuff, peru, pink, plum,
# powderblue, purple, rebeccapurple, rosybrown, royalblue, saddlebrown, salmon,
# sandybrown, seagreen, seashell, sienna, silver, skyblue, slateblue, slategray,
# snow, springgreen, steelblue, tan, teal, thistle, tomato, turquoise, violet,
# webgray, webgreen, webmaroon, webpurple, wheat, whitesmoke, yellowgreen

# This is too much work but it was a neat ideae
# puts line.split('').map(&:to_sym).map { |char| self.send(char) }.join
require 'rainbow'

module Root
  # This is going to be handling input / output for different screens
  module Display
    # We currently (and probably will only ever) display to terminal.
    # This handles all of that sort of logic here.
    class WoodlandsTerminal
      def initialize(game)
        @game = game
      end

      SUIT_COLOR = {
        fox: :firebrick,
        mouse: :orange,
        bunny: :yellow,
      }

      def display
        cls = game.board.clearings
        [
          n(0) + f(25),
          n(1) + f(2) + c(cls[:one])[0] + f(13),
          n(3) + f(2) + c(cls[:one])[1] + hp(13),
          n(4) + f(2) + c(cls[:one])[2] + f(13),
          n(5) + f(2) + c(cls[:one])[3] + f(13),
          n(6) + f(2) + c(cls[:one])[4] + dd + f(12),
          n(7) + f(2) + c(cls[:one])[5] + f(2) + dd + f(10),
          n(8) + f(4) + vp + f(11) + dd + f(8),
          n(9) + f(4) + vp + f(13) + dd + f(6),
        ].each do |line|
          puts line.join
        end
        ''
      end

      def n(number)
        [Rainbow(number.to_s.ljust(2)).lightslategray.faint]
      end

      def f(num = 1)
        Array.new(num) {  Rainbow('^').darkgreen }
      end

      def hp(num = 1)
        Array.new(num) {  Rainbow('-').goldenrod }
      end

      def vp(num = 1)
        Array.new(num) {  Rainbow('|').goldenrod }
      end

      def dd(num = 1)
        Array.new(num) {  Rainbow("\\").goldenrod }
      end

      def c(cl)
        color = SUIT_COLOR[cl.suit]
        hor = Rainbow('-').fg(color)
        cor = Rainbow('+').fg(color)
        ver = Rainbow('|').fg(color)
        dot = Rainbow('.').fg(:goldenrod)
        [
          [cor, hor, hor, hor, hor, hor, hor, hor, hor, cor],
          [ver, dot, dot, dot, dot, dot, dot, dot, dot, ver],
          [ver, dot, dot, dot, dot, dot, dot, dot, dot, ver],
          [ver, dot, dot, dot, dot, dot, dot, dot, dot, ver],
          [ver, dot, dot, dot, dot, dot, dot, dot, dot, ver],
          [cor, hor, hor, hor, hor, hor, hor, hor, hor, cor],
        ]
      end

      attr_reader :game
    end
  end
end
