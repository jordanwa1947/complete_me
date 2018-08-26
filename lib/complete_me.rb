require './lib/node'
require 'pry'

class CompleteMe
  attr_reader :root
  def initialize
    @word_count = 0
    @root = Node.new
  end

  def insert(word)
    @word_count += 1
    word_array = word.split('')
    add_node(word_array, @root)
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
    end
  end

  def populate(dictionary)
    array = dictionary.split("\n")
    array.each do |word|
      insert(word)
    end
  end

  def suggest(prefix)
    prefix_array = prefix.split("")
    target_node = traverse(prefix_array, @root)
    build(prefix, target_node)
  end

  def traverse(prefix, node)
    current_letter = prefix.first
    if node.children
      new_node = node.children[current_letter]
    end
    next_prefix = prefix.drop(1)
    if next_prefix.length > 0
      traverse(next_prefix, new_node)
    else
      return node
    end
  end

  def build(prefix, node)
    suggestions = []
    children = node.children.keys
    if !children.empty?
      children.each do |child|
        pending_node = node.children[child]
        if pending_node.complete_word == true
          suggestions << prefix + child
        end
        build(prefix + child, pending_node)
      end
    end
    return suggestions
  end
end
