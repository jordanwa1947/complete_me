class Node
  attr_reader :children, :value

  attr_accessor :complete_word
  
  def initialize(value = nil)
    @complete_word = false
    @children = {}
    @value = value
  end
end
