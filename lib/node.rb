class Node
  attr_reader :children, :value

  attr_accessor :complete_word, :word_score

  def initialize(value = nil)
    @complete_word = false
    @children = {}
    @value = value
    @word_score = 0
  end
end
