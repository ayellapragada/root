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
        mouse: :sandybrown,
        rabbit: :gold,
      }

      def display
        cls = game.board.clearings
        [
          n(0) + bf(70),
          n(1) + bf(32) + c(cls[:five])[0],
          n(2) + bf(2) + c(cls[:one])[0] + bf(20) + c(cls[:five])[1],
          n(3) + bf(2) + c(cls[:one])[1] + hp(20) + c(cls[:five])[2],
          n(4) + bf(2) + c(cls[:one])[2] + f(20) + c(cls[:five])[3],
          n(5) + bf(2) + c(cls[:one])[3] + f(20) + c(cls[:five])[4],
          n(6) + bf(2) + c(cls[:one])[4] + dd + f(19),
          n(7) + bf(14) + dd + f(21),
          n(8) + bf(7) + vp + f(8) + dd + f(14),
          n(9) + bf(7) + vp + f(10) + dd + f(3) + c(cls[:ten])[0] + f(4),
          n(9) + bf(7) + vp + f(12) + dd + f + c(cls[:ten])[1] + f(5),
          n(10) + bf(7) + vp + f(14) + c(cls[:ten])[2] + f(5),
          n(11) + bf(7) + vp + f(14) + c(cls[:ten])[3] + f(5),
          n(12) + bf(2) + c(cls[:nine])[0] + f(10) + c(cls[:ten])[4] + f(5),
          n(13) + bf(2) + c(cls[:nine])[1] + f(11) +  du + f(24),
          n(14) + bf(2) + c(cls[:nine])[2] + f(10) + du + f(24),
          n(15) + bf(2) + c(cls[:nine])[3] + f(9) + du + f(24),
          n(16) + bf(2) + c(cls[:nine])[4] + f(8) + du + f(24),
          n(17) + bf(7) + vp + f(4) + dd + f(3) + c(cls[:twelve])[0],
          n(18) + bf(7) + vp + f(6) + dd + f + c(cls[:twelve])[1],
          n(19) + bf(7) + vp + f(8) + c(cls[:twelve])[2],
          n(20) + bf(7) + vp + f(8) + c(cls[:twelve])[3] + dd,
          n(21) + bf(7) + vp + f(8) + c(cls[:twelve])[4] + f + dd,
          n(22) + bf(7) + vp + f(6) + du + f(14) + dd,
          n(23) + bf(7) + vp + f(5) + du + f(17) + dd + c(cls[:seven])[0],
          n(24) + bf(7) + vp + f(4) + du + f(19) + c(cls[:seven])[1],
          n(25) + bf(2) + c(cls[:four])[0] + f(19) + du + c(cls[:seven])[2] + dd,
          n(26) + bf(2) + c(cls[:four])[1] + dd + f(6) + c(cls[:eight])[0] + f + du + bf + c(cls[:seven])[3] + bf(2) + dd + f(2) + c(cls[:three])[0],
          n(27) + bf(2) + c(cls[:four])[2] + bf(2) + dd + f(4) + c(cls[:eight])[1] + du + bf(2) + c(cls[:seven])[4] + bf(4) + dd + c(cls[:three])[1],
          n(28) + bf(2) + c(cls[:four])[3] + bf(4) + dd + f(2) + c(cls[:eight])[2] + bf(18) + c(cls[:three])[2],
          n(29) + bf(2) + c(cls[:four])[4] + bf(6) + dd + c(cls[:eight])[3] + bf(18) + c(cls[:three])[3],
          n(30) + bf(19) + c(cls[:eight])[4] + bf(18) + c(cls[:three])[4],
          n(31) + bf(70),
        ].each do |line|
          puts line.join
        end
        ''
      end

      def n(number)
        [Rainbow(number.to_s.rjust(2)).lightslategray.faint]
      end

      def f(num = 1)
        Array.new(num) {  Rainbow("\u25B4").darkgreen }
      end

      def bf(num = 1)
        Array.new(num) {  Rainbow("\u25B4").darkolivegreen }
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

      def du(num = 1)
        Array.new(num) {  Rainbow("/").goldenrod }
      end

      def c(cl)
        color = SUIT_COLOR[cl.suit]
        hor = Rainbow('-').fg(color)
        cor = Rainbow('+').fg(color)
        ver = Rainbow('|').fg(color)
        dot = Rainbow("\u00B7").fg(:goldenrod)
        [
          [cor, hor, hor, hor, hor, hor, hor, hor, hor, cor],
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
