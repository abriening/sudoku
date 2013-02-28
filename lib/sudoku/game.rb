module Sudoku
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
end
