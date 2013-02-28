module Sudoku
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
end
