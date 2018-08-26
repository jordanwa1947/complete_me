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
    suggestion_hash = build(prefix, target_node, {})
    sort_suggestions(suggestion_hash)
  end

  def traverse(prefix, node)
    current_letter = prefix.first
    new_node = node.children[current_letter]
    next_prefix = prefix.drop(1)
    if next_prefix.length > 0
      traverse(next_prefix, new_node)
    else
      return new_node
    end
  end

  def build(prefix, node, suggestions)
    if node.complete_word
      suggestions[prefix] = node.word_score
    end
    children = node.children.keys
    if !children.empty?
      children.each do |child|
        new_prefix = prefix + child
        pending_node = node.children[child]
        build(new_prefix, pending_node, suggestions)
      end
    end
    return suggestions
  end

  def select(prefix, selection)
    selection_array = selection.split('')
    final_node = traverse(selection_array, @root)
    if final_node.complete_word
      final_node.word_score += 1
    else
      puts "selection is not a word"
    end
  end

  def sort_suggestions(hash)
    sorted_hash = hash.sort_by { |word, weight| weight * -1 }
    sorted_array = sorted_hash.to_h.keys
  end
end
