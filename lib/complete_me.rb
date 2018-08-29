require 'faraday'
require 'JSON'
require './data/key'
require './lib/node'

class CompleteMe
  attr_reader :root
  def initialize
    @root = Node.new
    @count = 0
  end

  def insert(word)
    word_array = word.split('')
    add_node(word_array, @root)
  end

  def count
    @count = 0
    word_count(@root)
    @count
  end

  def word_count(node)
    node.children.values.each do |child|
      if child.complete_word == true
         @count += 1
      end
      word_count(child)
    end
  end

  def add_node(word, parent_node)
    child_node = check_for_existing_child_node(word, parent_node)
    mature_child_node(word, child_node)
  end

  def check_for_existing_child_node(word, parent_node)
    child_char = word.first
    if !parent_node.children[child_char]
      child_node = Node.new(child_char)
      parent_node.children[child_char] = child_node
      return child_node
    else
      child_node = parent_node.children[child_char]
      return child_node
    end
  end

  def mature_child_node(word, child_node)
    new_word = word.drop(1)
    if new_word.length > 0
      new_child_node = check_for_existing_child_node(new_word, child_node)
      mature_child_node(new_word, new_child_node)
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
    if target_node != "Invalid prefix"
      suggestion_hash = build(prefix, prefix, target_node, {})
      clean_hash = clean_suggestions(suggestion_hash)
      sorted_hash = sort_suggestions(clean_hash)
      trim(sorted_hash)
    else 
      return ["No suggestions."]
    end
  end

  def traverse(prefix, node)
    current_letter = prefix.first
    if node.children[current_letter] != nil
      new_node = node.children[current_letter]
      next_prefix = prefix.drop(1)
      if next_prefix.length > 0
        traverse(next_prefix, new_node)
      else
        return new_node
      end
    else
      'Invalid prefix'
    end 
  end

  def build(original_prefix, prefix, node, suggestions)
    if node.complete_word
      suggestions[prefix] = node.word_score[original_prefix]
    end
    child_keys = node.children.keys
    if !child_keys.empty?
      child_keys.each do |child_key|
        new_prefix = prefix + child_key
        pending_node = node.children[child_key]
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
    response = get_fetch(word, keys, url, conn)
    evaluate_fetch_response(word, response)
  end

  def get_fetch(word, keys, url, conn)
    conn.get "#{url}#{word}", 
      {}, #parameters
      {   #headers
        "Accept" => "application/json",
        "app_id" => keys.id,
        "app_key" => keys.key
      }
  end

  def evaluate_fetch_response(word, response)
    if response.status == 200
      result = JSON.parse(response.body)
      result["results"][0]["lexicalEntries"][0]["entries"][0]["senses"][0]["definitions"][0]
    elsif response.status == 404
      "No definition found for #{word} (status: 404)"
    else
      "Something went wrong (status: #{response.status}"
    end
  end

  def clean_suggestions(suggestion_hash)
    suggestion_hash.keys.each do |word|
      if suggestion_hash[word] == nil
        suggestion_hash[word] = 0
      end
    end
    suggestion_hash
  end

  def sort_suggestions(suggestion_hash)
    sorted_hash = suggestion_hash.sort_by { |character, weight| [-weight, character] }
    sorted_hash.to_h.keys
  end

  def trim(suggestion_array)
    if suggestion_array.length > 5
      suggestion_array.take(5)
    else
      suggestion_array
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
      parent_node.children.delete(child_node.character)
      traverse_deleted_word(word_array[0...-1])
    else
      parent_node.children.delete(child_node.character)
    end
  end
end
