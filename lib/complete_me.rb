require './lib/node'
require 'pry'

class CompleteMe
  attr_reader :root
  def initialize
    @word_count = 0
    @root = Node.new
  end

  def insert(word)
    word_array = word.split('')
    word_array.shift
    word_array.each do |char|
      node = Node.new(char)
      @root.children[char] = node
    end
    @word_count += 1
  end

  def count
    @word_count
  end

  def add_node(word, parent_node)
    child_char = word.shift
    child_node = Node.new(child_char)

    parent_node.children[child_char] = child_node
    new_word = word.drop(1)
    add_node(new_word, child_node) if new_word.length > 0
    binding.pry
  end
end

complete_me = CompleteMe.new
complete_me.insert("pizza")
complete_me.add_node('pizza'.split(''), complete_me.root)
