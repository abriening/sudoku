require 'rubygems'
require 'json'
$:.unshift File.dirname(__FILE__)

module Sudoku

  VERSION = "0.0.0" unless defined?(VERSION)

  autoload :Game,    "sudoku/game"
  autoload :Answer,  "sudoku/answer"
  autoload :Set,     "sudoku/set"
end
