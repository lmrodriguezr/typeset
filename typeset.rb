#!/usr/bin/env ruby

class Keyboard
  attr :name, :rows
  @@xdist = 19.05
  @@ydist = 19.05

  class << self
    def create(type)
      type = type.to_s.downcase.to_sym
      send(type) if supported.include? type
    end

    def supported
      %i[querty]
    end

    def qwerty
      Keyboard.new(
        :qwerty,
        [
          %w[q w e r t y u i o p],
          %w[a s d f g h j k l],
          %w[z x c v b n m]
        ]
      )
    end
  end

  def initialize(name, rows)
    @name = name.to_sym
    @rows = rows
  end

  def xy(key)
    @xy ||= {}
    return @xy[key] if @xy[key]
    row = row(key)
    col = rows[row].index(key)
    offset = [0.0, 0.25, 0.75][row]
    @xy[key] = [@@xdist * (offset + col), @@ydist * (-1.0 * row)]
  end

  def row(key)
    rows.each_with_index.find { |i, _| i.include? key }[1]
  end

  def dist(key1, key2)
    @dist ||= {}
    cann = [key1, key2].sort.join
    return @dist[cann] if @dist[cann]
    a = xy(key1)
    b = xy(key2)
    @dist[cann] = Math.sqrt(((a[0] - b[0]) ** 2) + (a[1] - b[1]) ** 2).round(2)
  end
end

class Typer
  attr :keyboard, :start, :onsite

  def initialize(keyboard = nil)
    @keyboard = keyboard || Keyboard.qwerty
    @onsite ||= false
  end

  def onsite!
    @onsite = true
  end

  def type_dist
    raise NotImplementedError
  end

  def clean(word)
    word.downcase.gsub(/[^a-z]/, '')
  end

  def split_word(word)
    clean(word).split('')
  end
end

class OneFingerTyper < Typer
  def initialize(keyboard = nil)
    super
    @start = %w[h]
  end

  def type_dist(word)
    vec = (onsite ? [] : start) + split_word(word)
    vec.each_with_index.map do |i, k|
      next if k == 0
      keyboard.dist(vec[k - 1], i)
    end.compact.inject(0.0, :+).round(2)
  end
end

class TwoFingerTyper < Typer
  def initialize(keyboard = nil)
    super
    @start = %w[f j]
  end

  def type_dist(word)
    vec = split_word(word)
    pos = start.dup
    ini = [true, true]
    dist = 0.0
    vec.each_with_index do |key, k|
      f = finger(key, pos)
      dist += keyboard.dist(pos[f], key) unless onsite && ini[f]
      ini[f] = false
      pos[f] = key # <- update finger position
    end
    dist.round(2)
  end

  def finger(key, centers = @start)
    [0, 1].map { |i| keyboard.dist(centers[i], key) }.inject(:-) < 0 ? 0 : 1
  end
end

#=================== MAIN

require 'optparse'

o = { keyboard: 'qwerty', method: TwoFingerTyper, onsite: false, quiet: false }
OptionParser.new do |opts|
  opts.banner = <<~BANNER

  Estimate traveling distances when typing
  Why? https://www.youtube.com/watch?v=Mf2H9WZSIyw

  Usage: #{$0} [options]
  BANNER

  opts.separator ''
  opts.on(
    '-k', '--keyboard STRING',
    'Keyboard layout. Supported: qwerty (default)'
  ) { |v| o[:keyboard] = v }
  opts.on(
    '--onsite',
    'Type starting from the initial letter (as in the video)',
    'By default: start in H for one-finger or F/J for two-finger'
  ) { |v| o[:onsite] = v }
  opts.on(
    '-1', '--one-finger', 'Typing method: One-finger pecker'
  ) { |v| o[:method] = OneFingerTyper }
  opts.on(
    '-2', '--two-finger', 'Typing method: Two-finger pecker (default)'
  ) { |v| o[:method] = TwoFingerTyper }
  opts.on(
    '-o', '--output FILE',
    'Save distances per line: total and per-character (tab-delimited)'
  ) { |v| o[:output] = v }
  opts.on(
    '-q', '--quiet',
    'Do not print the distances of each line'
  ) { |v| o[:quiet] = v }
  opts.on('-h', '--help', 'Display this screen') { puts opts ; exit }
  opts.separator ''
end.parse!

t = o[:method].new(Keyboard.create(o[:keyboard]))
t.onsite! if o[:onsite]
total = 0.0
ofh = nil
ofh = File.open(o[:output], 'w') if o[:output]

$stdin.each do |ln|
  d = t.type_dist(ln)
  total += d
  dpc = (d / t.clean(ln).size).round(2)
  puts "Travel: #{d} mm or #{dpc} mm/character" unless o[:quiet]
  ofh.puts "#{d}\t#{dpc}" if ofh
end

ofh.close if ofh
puts "Total travel: #{total.round(2)} mm"

