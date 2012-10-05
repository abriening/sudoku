Sudoku Solver
=============

Just for fun. Read in a json file with 81 numbers, will solve and print the solution.

Usage
-----

In irb:

    require 'lib/sudoku.rb'
    game = Sudoku::Game.new
    game.load_gamefile 'test/fixtures/game.json'
    game.solve # => true
    puts game

TODO
----

* Add more puzzles for testing
* Handle unsolvable puzzles
* Handle puzzles with multiple solutions (more common with *hard* puzzles)
* CLI:
    * Read json: sudoku [json filename]
    * Read [Rubyquiz](http://rubyquiz.com/quiz43.html) format: sudoku <stdin>
* Image processing? (ie read the puzzle from an image)
    * [Tesseract OCR](http://code.google.com/p/tesseract-ocr/)
* Fix stack level error when inspecting objects (recursive relationships make an infinite loop)
