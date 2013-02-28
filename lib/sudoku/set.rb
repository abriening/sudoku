module Sudoku
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
