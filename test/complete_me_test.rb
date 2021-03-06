require './test/helper_test'
require './lib/complete_me'
require './lib/node'

class CompleteMeTest < Minitest::Test

  def test_that_the_complete_me_class_exists
    completion = CompleteMe.new

    assert_instance_of CompleteMe, completion
  end

  def test_it_can_count
    completion = CompleteMe.new
    completion.insert('pizza')
    completion.insert('hello')

    assert_equal 2, completion.count
  end

  def test_it_can_create_root_node
    completion = CompleteMe.new

    assert_equal ({}), completion.root.children
    assert_instance_of Node, completion.root
  end

  def test_it_can_add_single_character
    completion = CompleteMe.new
    completion.insert("s")

    assert_equal "s", completion.root.children["s"].character
  end

  def test_it_checks_for_existing_child
    completion = CompleteMe.new
    completion.insert('s')
    expected = completion.root.children["s"]
    actual = completion.check_for_existing_child_node(['s'], completion.root)

    assert_equal expected, actual
  end

  def test_it_can_mature_a_child_node 
    completion = CompleteMe.new
    completion.insert('as')
    a_node = completion.root.children['a']
    s_node = a_node.children['s']

    assert_equal ['s'], a_node.children.keys
    assert s_node.complete_word
  end

  def test_it_can_add_a_single_word
    completion = CompleteMe.new
    completion.insert('pizza')

    p_node = completion.root.children["p"]
    i_node = p_node.children["i"]
    z_node = i_node.children["z"]
    z_two_node = z_node.children["z"]
    a_node = z_two_node.children["a"]

    assert_equal "p", p_node.character
    assert_equal "i", i_node.character
    assert_equal "z", z_node.character
    assert_equal "z", z_two_node.character
    assert_equal "a", a_node.character
    assert a_node.complete_word
  end

  def test_it_can_populate_words
    completion = CompleteMe.new
    dictionary = File.read("/usr/share/dict/words")
    completion.populate(dictionary)

    assert_equal 235886, completion.count
  end

  def test_it_doesnt_error_out_when_prefix_is_invalid
    completion = CompleteMe.new
    dictionary = File.read("/usr/share/dict/words")
    completion.populate(dictionary)

    actual = completion.traverse('vjx'.split(''), completion.root)

    assert_equal 'Invalid prefix', actual
  end

  def test_it_can_suggest_words
    completion = CompleteMe.new
    dictionary = File.read("/usr/share/dict/words")
    completion.populate(dictionary)

    expected = ["pize", "pizza", "pizzeria", "pizzicato", "pizzle"]

    assert_equal expected, completion.suggest("piz")
  end

  def test_that_it_can_suggest_based_on_word_score
    completion = CompleteMe.new
    dictionary = File.read("/usr/share/dict/words")
    completion.populate(dictionary)
    completion.suggest('piz')
    completion.select("piz", "pizzeria")
    expected = ["pizzeria", "pize", "pizza", "pizzicato", "pizzle"]

    assert_equal expected, completion.suggest('piz')
  end

  def test_that_it_can_suggest_based_on_prefix_score_combination
    completion = CompleteMe.new
    dictionary = File.read("/usr/share/dict/words")
    completion.populate(dictionary)

    completion.select("piz", "pizzeria")
    completion.select("piz", "pizzeria")
    completion.select("piz", "pizzeria")

    completion.select("pi", "pizza")
    completion.select("pi", "pizza")
    completion.select("pi", "pizzicato")

    expected = ["pizzeria", "pize", "pizza", "pizzicato", "pizzle"]
    assert_equal expected, completion.suggest('piz')

    expected = ["pizza", "pizzicato", "pi", "pia", "piaba"]
    assert_equal expected, completion.suggest('pi')
  end

  def test_it_knows_when_no_suggestions_to_be_made
    completion = CompleteMe.new
    dictionary = File.read("/usr/share/dict/words")
    completion.populate(dictionary)
    assert_equal ["No suggestions."], completion.suggest("asdf")

  end

  def test_it_returns_a_node_as_not_a_complete_word
    completion = CompleteMe.new
    dictionary = "try\ntrying\ntryout"
    completion.populate(dictionary)

    expected = ["try", "trying", "tryout"]
    assert_equal  expected, completion.suggest('try')

    word_array = "try".split('')
    node = completion.mark_as_not_a_word(word_array)
    refute node.complete_word
  end

  def test_it_traverses_a_deleted_word
    completion = CompleteMe.new
    dictionary = "try\ntrying\ntryout"
    completion.populate(dictionary)
    word_array = "tryout".split('')
    completion.traverse_deleted_word(word_array)

    i_node = completion.root.children["t"]
                            .children["r"]
                            .children["y"]
                            .children["i"]
    expected = {"i" => i_node}
    actual = completion.root.children["t"]
                            .children["r"]
                            .children["y"].children
    assert_equal expected, actual
  end

  def test_it_deletes_orphan_nodes
    completion = CompleteMe.new
    dictionary = "try\ntrying\ntryout"
    completion.populate(dictionary)
    word_array = "tryout".split('')
    completion.traverse_deleted_word(word_array)

    i_node = completion.root.children["t"]
                            .children["r"]
                            .children["y"]
                            .children["i"]
    expected = {"i" => i_node}
    actual = completion.root.children["t"]
                            .children["r"]
                            .children["y"].children
    assert_equal expected, actual

  end

  def test_it_deletes_a_word_with_child_nodes
    completion = CompleteMe.new
    dictionary = "try\ntrying\ntryout"
    completion.populate(dictionary)

    completion.delete_word('try')

    expected = ["trying", "tryout"]
    assert_equal expected, completion.suggest('try')
  end

  def test_it_deletes_a_word_without_child_nodes
    completion = CompleteMe.new
    dictionary = "try\ntrying\ntryout"
    completion.populate(dictionary)

    completion.delete_word('trying')

    expected = ["try", "tryout"]
    assert_equal expected, completion.suggest('try')
  end

  def test_it_can_populate_addresses
    completion = CompleteMe.new
    relative_path = "./data/addresses"
    absolute_path = File.expand_path(relative_path)
    addresses = File.read(absolute_path)
    completion.populate(addresses)

    assert_equal 313415, completion.count
  end

  def test_it_can_suggest_addresses
    completion = CompleteMe.new
    relative_path = "./data/addresses"
    absolute_path = File.expand_path(relative_path)
    addresses = File.read(absolute_path)
    completion.populate(addresses)

    expected = ["1234 E 22nd Ave",
                "1234 E 27th Ave",
                "1234 E 28th Ave",
                "1234 E 33rd Ave",
                "1234 E Colfax Ave"]

    assert_equal expected, completion.suggest("1234")
  end

  def test_that_it_can_suggest_addresses_based_on_word_score
    completion = CompleteMe.new
    relative_path = "./data/addresses"
    absolute_path = File.expand_path(relative_path)
    addresses = File.read(absolute_path)
    completion.populate(addresses)

    completion.select("1234", "1234 E Colfax Ave")
    completion.suggest("1234")

    expected = ["1234 E Colfax Ave",
                "1234 E 22nd Ave",
                "1234 E 27th Ave",
                "1234 E 28th Ave",
                "1234 E 33rd Ave"]

    assert_equal expected, completion.suggest("1234")
  end

  def test_that_it_can_suggest_an_address_based_on_prefix_score_combination
    completion = CompleteMe.new
    relative_path = "./data/addresses"
    absolute_path = File.expand_path(relative_path)
    addresses = File.read(absolute_path)
    completion.populate(addresses)

    completion.select("1234", "1234 E Colfax Ave")
    completion.select("1234", "1234 E Colfax Ave")
    completion.select("1234", "1234 E Colfax Ave")
    completion.suggest("1234")

    completion.select("123", "1234 E 22nd Ave")
    completion.select("123", "1234 E 22nd Ave")
    completion.select("123", "1234 E 28th Ave")

    expected = ["1234 E Colfax Ave",
                "1234 E 22nd Ave",
                "1234 E 27th Ave",
                "1234 E 28th Ave",
                "1234 E 33rd Ave"]
    assert_equal expected, completion.suggest('1234')

    expected = ["1234 E 22nd Ave",
                "1234 E 28th Ave",
                "123 E 2nd Ave",
                "123 E 3rd Ave",
                "123 E 3rd Ave Apt 1"]
    assert_equal expected, completion.suggest('123')
  end

  def test_it_deletes_an_address
    completion = CompleteMe.new
    relative_path = "./data/addresses"
    absolute_path = File.expand_path(relative_path)
    addresses = File.read(absolute_path)
    completion.populate(addresses)

    expected = ["1234 E 22nd Ave", "1234 E 27th Ave", "1234 E 28th Ave"]
    assert_equal expected, completion.suggest('1234 E 2')

    completion.delete_word('1234 E 22nd Ave')

    expected = ["1234 E 27th Ave", "1234 E 28th Ave"]
    assert_equal expected, completion.suggest('1234 E 2')
  end

  def test_it_returns_a_definition
    completion = CompleteMe.new

    expected = "a human being regarded as an individual"
    actual = completion.fetch_definition("person")
    assert_equal expected, actual
  end

  def test_it_returns_an_error_when_no_definition_found
    completion = CompleteMe.new

    expected = "No definition found for trie (status: 404)"
    actual = completion.fetch_definition("trie")
    assert_equal expected, actual
  end

  def test_it_can_fetch_using_get_method
    completion = CompleteMe.new
    word = "test"
    keys = Key.new
    url = "https://od-api.oxforddictionaries.com:443/api/v1/entries/en/"
    conn = Faraday.new
    response = completion.get_fetch(word, keys, url, conn)
    result = JSON.parse(response.body)

    assert_equal "test", result["results"][0]["id"]
  end

  def test_it_can_evaluate_a_fetch_response
    completion = CompleteMe.new
    word = "person"
    keys = Key.new
    url = "https://od-api.oxforddictionaries.com:443/api/v1/entries/en/"
    conn = Faraday.new
    response = completion.get_fetch(word, keys, url, conn)

    expected = "a human being regarded as an individual"
    actual = completion.evaluate_fetch_response(word, response)
    assert_equal expected, actual

    word = "pursun"
    response = completion.get_fetch(word, keys, url, conn)

    expected = "No definition found for pursun (status: 404)"
    actual = completion.evaluate_fetch_response(word, response)
    assert_equal expected, actual

    url = "https://od-api.oxforddictionaries.com:443/api/wtf/"
    response = completion.get_fetch(word, keys, url, conn)

  end
end
