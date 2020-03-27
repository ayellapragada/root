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
        fr = game.board.forests
        [
          n(0) + bf(40) + dur(2) + bf(29),
          n(1) + bf(33) + c(cls[:five])[0] + bf(27),
          n(2) + bf(2) + c(cls[:one])[0] + bf(20) + c(cls[:five])[1] + bf(27),
          n(3) + bf(2) + c(cls[:one])[1] + hp(20) + c(cls[:five])[2] + dd(3) + bf(24),
          n(4) + bf(2) + c(cls[:one])[2] + f(20) + c(cls[:five])[3] + f(4) + dd + bf(22),
          n(5) + bf(2) + c(cls[:one])[3] + f(20) + c(cls[:five])[4] + f(6) + dd + bf(20),
          n(6) + bf(2) + c(cls[:one])[4] + dd + f(20) + dur(2) + f(16) + dd + bf(18),
          n(7) + bf(7) + vp + f(6) + dd + f(12) + fc(fr[:a]) + f(3) + dub(2) + f(19) + dd + bf(3) + c(cls[:two])[0] + bf(2),
          n(8) + bf(7) + vp + f(8) + dd + f(15) + dur(2) + f(22) + dd(2) + c(cls[:two])[1] + bf(2),
          n(9) + bf(7) + vp + f(10) + dd + f(4) + c(cls[:ten])[0] + f(24) + c(cls[:two])[2] + bf(2),
          n(10) + bf(7) + vp + f(12) + dd(3) + c(cls[:ten])[1] + hp(24) + c(cls[:two])[3] + bf(2),
          n(11) + bf(7) + vp + f(15) + c(cls[:ten])[2] + f(5) + f(19) + c(cls[:two])[4] + bf(2),
          n(12) + bf(7) + vp + f(8) +fc(fr[:b]) + f(4) + c(cls[:ten])[3] + f(5) + f(22) + vp + bf(9),
          n(13) + bf(2) + c(cls[:nine])[0] + f(10) + c(cls[:ten])[4] + f(12) + fc(fr[:c]) + f(12) + vp + bf(9),
          n(14) + bf(2) + c(cls[:nine])[1] + f(11) +  du + f(8) + ddb(2) + f(26) + vp + bf(9),
          n(15) + bf(2) + c(cls[:nine])[2] + f(10) + du + f(11) + ddr(7) + f(19) + vp + bf(9),
          n(16) + bf(2) + c(cls[:nine])[3] + f(9) + du + f(17) + c(cls[:eleven])[0] + f(10) + vp + bf(9),
          n(17) + bf(2) + c(cls[:nine])[4] + f(8) + du + f(18) + c(cls[:eleven])[1] + f(6) + c(cls[:six])[0] + bf(3),
          n(18) + bf(7) + vp + f(4) + dd + f(3) + c(cls[:twelve])[0] + f(13) + c(cls[:eleven])[2] + hp(6) + c(cls[:six])[1] + bf(3),
          n(19) + bf(7) + vp + f(6) + dd(2) + c(cls[:twelve])[1] + hp(13) + c(cls[:eleven])[3] + f(6) + c(cls[:six])[2] + bf(3),
          n(20) + bf(7) + vp + f(8) + c(cls[:twelve])[2] + f(13) + c(cls[:eleven])[4] + f(6) + c(cls[:six])[3] + bf(3),
          n(21) + bf(7) + vp + f(3) +fc(fr[:d]) + f(2) + c(cls[:twelve])[3] + dd + f(5) + fc(fr[:f]) + f(5) + dur(2) + f(3) + dd + f(10) + c(cls[:six])[4] + bf(3),
          n(22) + bf(7) + vp + f(8) + c(cls[:twelve])[4] + f(2) + dd + f(10) + dub(2) + f(5) + dd + f(13) + du + bf(9),
          n(23) + bf(7) + vp + f(6) + du + f(16) + dd + f(7) +  dur(2) + f(7) + dd + f(4) + fc(fr[:g]) + f(4) + du + bf(10),
          n(24) + bf(7) + vp + f(5) + du + f(6) +fc(fr[:e]) + f(10) + dd + c(cls[:seven])[0] + f(4) + dd + f(4) + f(5) + du + bf(11),
          n(25) + bf(7) + vp + f(4) + du + f(5) + dur(4) + dub(2) + dur(8) + f(2) + c(cls[:seven])[1] + f(5) + dd + f(7) + du + bf(12),
          n(26) + bf(2) + c(cls[:four])[0] + dur(6) + f(10) + dur(5) + c(cls[:seven])[2] + dd + f(5) + dd + f(5) + du + bf(13),
          n(27) + bf(2) + c(cls[:four])[1] + dd + f(6) + c(cls[:eight])[0] + f(2) + du + c(cls[:seven])[3] + bf(2) + dd + f(2) + c(cls[:three])[0] + bf(10),
          n(28) + bf(2) + c(cls[:four])[2] + bf(2) + dd + f(4) + c(cls[:eight])[1] + du + bf(2) + c(cls[:seven])[4] + bf(4) + dd + c(cls[:three])[1] + bf(10),
          n(29) + dur(2) + c(cls[:four])[3] + bf(4) + dd + f(2) + c(cls[:eight])[2] + bf(19) + c(cls[:three])[2] + bf(10),
          n(30) + bf(2) + c(cls[:four])[4] + bf(6) + dd + c(cls[:eight])[3] + bf(19) + c(cls[:three])[3] + bf(10),
          n(31) + bf(20) + c(cls[:eight])[4] + bf(19) + c(cls[:three])[4] + bf(10),
          n(32) + bf(71),
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
        Array.new(num) {  Rainbow("\u25B4").darkolivegreen.faint }
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

      def vpr(num = 1)
        Array.new(num) {  Rainbow('|').royalblue }
      end

      def ddr(num = 1)
        Array.new(num) {  Rainbow("\\").royalblue }
      end

      def dur(num = 1)
        Array.new(num) {  Rainbow("/").royalblue }
      end

      def ddb(num = 1)
        Array.new(num) {  Rainbow("\\").peru.faint }
      end

      def dub(num = 1)
        Array.new(num) {  Rainbow("/").peru.faint }
      end

      def fc(forest)
        @pieces = forest.meeples
        if forest.meeples.count == 1
          [ f, dot, f ]
        elsif forest.meeples.count == 2
          [ dot, f, dot ]
        else
          f(3)
        end.tap do
          @pieces = forest.meeples
        end
      end

      def c(cl)
        co = SUIT_COLOR[cl.suit]
        hor = Rainbow('-').fg(co)
        cor = Rainbow('+').fg(co)
        ver = Rainbow('|').fg(co)

        # Going to do some fky instance variables thing with dot
        @buildings = cl.buildings_with_empties
        @pieces = (cl.tokens + cl.meeples)

        if cl.priority == 4
          [
            [cor, hor, hor, hor, hor, hor, hor, hor, hor, hor, dur],
            [ver, dot(8), dur, ver],
            [ver, dot(1), dur, dur(5), dur, dot, ver],
            [dur, dur, dot(8), ver],
            [cor, hor, hor, hor, hor, hor, hor, hor, hor, hor, cor],
          ]
        elsif cl.priority == 5
          [
            [cor, hor, hor, hor, hor, hor, dur, dur, hor, hor, cor],
            [ver, dot(4), dur(2), dot(3), ver],
            [ver, dot(3), dur(2), dot(4), ver],
            [ver, dot(2), dur(2), dot(5),ver],
            [cor, hor, dur, dur, hor, hor, hor, hor, hor, hor, cor],
          ]
        elsif cl.priority == 7
          [
            [cor, hor, hor, hor, dur, dur, hor, hor, hor, hor, cor],
            [ver, dot(2), dur(2), dot(5), ver],
            [dur, dur(2), dot(7), ver],
            [ver, dot(9), ver],
            [cor, hor, hor, hor, hor, hor, hor, hor, hor, hor, cor],
          ]
        elsif cl.priority == 10
          [
            [cor, hor, hor, hor, hor, hor, hor, hor, dur, dur, cor],
            [ver, dot(6), dur(2), dot, ver],
            [ver, dot(6), vpr(2), dot, ver],
            [ver, dot(6), ddr(2), dot, ver],
            [cor, hor, hor, hor, hor, hor, hor, hor, ddr, ddr, cor],
          ]
        elsif cl.priority == 11
          [
            [cor, hor, ddr, ddr, hor, hor, hor, hor, hor, hor, cor],
            [ver, dot(2), vpr(2), dot(5), ver],
            [ver, dot(2), vpr(2), dot(5), ver],
            [ver, dot(2), vpr(2), dot(5), ver],
            [cor, hor, dur, dur, hor, hor, hor, hor, hor, hor, cor],
          ]
        else
          [
            [cor, hor, hor, hor, hor, hor, hor, hor, hor, hor, cor],
            [ver, dot(9), ver],
            [ver, dot(9), ver],
            [ver, dot(9), ver],
            [cor, hor, hor, hor, hor, hor, hor, hor, hor, hor, cor],
          ]
        end.tap do
          @buildings = []
          @pieces = []
        end
      end

      def dot(num = 1)
        res = []
        num.times do |i|
          if @pieces.empty? && @buildings.empty?
            res << Rainbow("\u00B7").fg(:lightgoldenrod).faint
          elsif @buildings.empty?
            pie = @pieces.shift
            res << Rainbow(pie.display_symbol).color(pie.display_color)
          else
            build = @buildings.shift
            res << Rainbow(build.display_symbol).color(build.display_color).bright.underline
          end
        end

        res
      end

      attr_reader :game
    end
  end
end
