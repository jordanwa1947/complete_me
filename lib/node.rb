class Node
  attr_reader :children, :complete_word, :value
  def initialize(value = nil)
    @complete_word = false
    @children = {}
    @value = value
  end
end
