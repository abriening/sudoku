require 'rubygems'
require 'json'

module Sudoku

  VERSION = "0.0.0" unless defined?(VERSION)

  # autoload :Game,    "sudoku/game"
  # autoload :Answer,  "sudoku/answer"
  # autoload :Set,     "sudoku/set"

  class Game
    attr_accessor :answers, :sets

    def initialize
      @answers = (0..80).map{|index| Answer.new(index) }
      @sets = []

      rows = @answers.dup
      9.times{ set rows.shift(9), 'row' }

      9.times{ |n| column @answers.dup, n }

      [0,3,6,27,30,33,54,57,60].each do |n|
         box @answers.dup, n
      end
    end

    def load_gamefile(file)
      self.defaults JSON.parse(File.read(file)).flatten
    end

    def defaults(defaults)
      @answers.each_with_index do |answer, id|
        if value = defaults[id] and !value.zero?
          answer.default =  value
        end
      end
      self
    end

    def set(answers, type)
      @sets << Set.new(answers, type)
    end

    def column(answers, offset=0)
      box(answers, offset, 1, 8, 'column')
    end

    def box(answers, offset=0, take=3, leave=6, type='box')
      answers.shift(offset)
      set = []
      until set.size == 9
        set += answers.shift(take)
        answers.shift(leave)
      end
      set(set, type)
    end

    def unsolved
      @answers.select &:unsolved?
    end

    def solve(count = unsolved.size)
      @sets.each{|set| set.solve }
      if count != (new_count = unsolved.size)
        solve new_count
      end
      unsolved.size.zero?
    end

    def inspect
      '#<%s:0x%s>' % [self.class, object_id.to_s(16)]
    end

    def print(method=:value)
      border = "+-------+-------+-------+"
      result = []
      rows = @sets.select{|set| set.type == 'row' }
      rows.each_with_index do |row, rid|
        result << border if rid % 3 == 0
        r = []
        row.answers.each_with_index do |answer, cid|
          r << '|' if cid % 3 == 0
          r << "#{answer.send(method) || '_'}"
        end
        result << "#{r.join(' ')} |"
      end
      result << border
      result.join("\n")
    end

    def to_s
      print :value
    end
  end

  class Answer
    attr_accessor :value, :guesses, :default, :index, :sets

    def initialize(index)
      @index = index
      @sets = []
      @guesses = (1..9).to_a
    end

    def default=(value)
      unless value.nil?
        solve value
      end
      @value = @default = value
    end

    def solve(value)
      @guesses.clear
      @value = value
      remove_guesses value
    end

    def remove_guesses(value)
      @sets.each{|set| set.remove_guesses(value) }
    end

    def remove_guess(value)
      raise "#{index} only has one guess #{guesses.inspect} can't remove #{value}" if guesses == [value]
      guesses.delete(value)
      if guesses.size == 1
        solve guesses.first
      end
    end

    def unsolved?
      @value.nil?
    end

    def to_s
      '%02s' % (value || '_')
    end
  end

  class Set
    attr_accessor :answers, :type

    def initialize(answers, type)
      @answers, @type = answers, type
      @answers.each do |answer|
        answer.sets << self
      end
    end

    def unsolved
      @answers.select &:unsolved?
    end

    def remove_guesses(value)
      @answers.each{|answer| answer.remove_guess(value) }
    end

    def solve
      only_guess
      only_match
    end

    def only_guess
      unsolved.select{|s| s.guesses.size == 1 }.map{|s| s.solve s.guesses.first  }
    end

    def only_match
      unsolved.inject({}) do |matches,s|
        s.guesses.each do |guess|
          matches[guess] ||= []
          matches[guess] << s
        end
        matches
      end.each do |guess, set|
        if set.size == 1
          set.first.solve guess
        end
      end
    end
  end
end
