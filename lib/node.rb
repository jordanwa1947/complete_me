class Node
  attr_reader :value

  attr_accessor :complete_word, :word_score, :children

  def initialize(value = nil)
    @complete_word = false
    @children = {}
    @value = value
    @word_score = {}
  end
end
