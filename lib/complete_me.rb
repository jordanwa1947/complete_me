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
    add_node(word_array, @root)
    @word_count += 1
  end

  def count
    @word_count
  end

  def add_node(word, parent_node)
    child_char = word.first
    if !parent_node.children[child_char]
      child_node = Node.new(child_char)
      parent_node.children[child_char] = child_node
    else
      child_node = parent_node.children[child_char]
    end
    new_word = word.drop(1)
    if new_word.length > 0
      add_node(new_word, child_node) 
    else 
      child_node.complete_word = true
      binding.pry
    end
  end
end

complete_me = CompleteMe.new
complete_me.insert("pizza")
complete_me.insert("pop")
complete_me.insert("poop")
complete_me.insert("other")
