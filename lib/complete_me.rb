require 'faraday'
require 'JSON'
require './data/key'
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
    suggestion_hash = build(prefix, prefix, target_node, {})
    clean_hash = clean_suggestions(suggestion_hash)
    sorted_hash = sort_suggestions(clean_hash)
    trim(sorted_hash)
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

  def build(original_prefix, prefix, node, suggestions)
    if node.complete_word
      suggestions[prefix] = node.word_score[original_prefix]
    end
    children = node.children.keys
    if !children.empty?
      children.each do |child|
        new_prefix = prefix + child
        pending_node = node.children[child]
        build(original_prefix, new_prefix, pending_node, suggestions)
      end
    end
    return suggestions
  end

  def select(prefix, selection)
    selection_array = selection.split('')
    final_node = traverse(selection_array, @root)
    if final_node.complete_word
      if final_node.word_score.keys.include?(prefix)
        final_node.word_score[prefix] += 1
      else
        final_node.word_score[prefix] = 1
      end
    else
      puts "selection is not a word"
    end
  end

  def fetch_definition(word)
    keys = Key.new
    url = "https://od-api.oxforddictionaries.com:443/api/v1/entries/en/"
    conn = Faraday.new
    response = conn.get "#{url}#{word}", 
      {}, #parameters
      {   #headers
        "Accept" => "application/json",
        "app_id" => keys.id,
        "app_key" => keys.key
      }
      if response.status == 200
        result = JSON.parse(response.body)
        result["results"][0]["lexicalEntries"][0]["entries"][0]["senses"][0]["definitions"][0]
      elsif response.status == 404
        "No definition found for #{word} (status: 404)"
      else
        "Something went wrong (status: #{response.status}"
      end
    end

  def clean_suggestions(params)
    params.keys.each do |word|
      if params[word] == nil
        params[word] = 0
      end
    end
    params
  end

  def sort_suggestions(params)
    sorted_hash = params.sort_by { |_, weight| weight * -1 }
    sorted_hash.to_h.keys
  end

  def trim(params)
    if params.length > 5
      params.take(5)
    else
      params
    end
  end

  def delete_word(word)
    word_array = word.split('')
    node = mark_as_not_a_word(word_array)
    if node.children.keys.length == 0
      traverse_deleted_word(word_array)
    end
  end

  def mark_as_not_a_word(word_array)
    node = traverse(word_array, @root)
    node.complete_word = false
    node
  end

  def traverse_deleted_word(word_array)
    child_node = traverse(word_array, @root)
    parent_node = traverse(word_array[0...-1], @root)
    delete_orphan_nodes(word_array, child_node, parent_node)
  end

  def delete_orphan_nodes(word_array, child_node, parent_node)
    if parent_node.children.keys.length == 1
      parent_node.children.delete(child_node.value)
      traverse_deleted_word(word_array[0...-1])
    else
      parent_node.children.delete(child_node.value)
    end
  end
end
