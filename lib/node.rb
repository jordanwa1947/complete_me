class Node
  attr_reader :character

  attr_accessor :complete_word, :word_score, :children

  def initialize(character = nil)
    @complete_word = false
    @children = {}
    @character = character
    @word_score = {}
  end
end
