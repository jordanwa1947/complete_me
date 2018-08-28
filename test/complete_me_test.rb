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

    assert_equal "s", completion.root.children["s"].value
  end

  def test_it_can_add_a_single_word
    completion = CompleteMe.new
    completion.insert('pizza')

    p_node = completion.root.children["p"]
    i_node = p_node.children["i"]
    z_node = i_node.children["z"]
    z_two_node = z_node.children["z"]
    a_node = z_two_node.children["a"]

    assert_equal "p", p_node.value
    assert_equal "i", i_node.value
    assert_equal "z", z_node.value
    assert_equal "z", z_two_node.value
    assert_equal "a", a_node.value
    assert a_node.complete_word
  end

  def test_it_can_populate_words
    completion = CompleteMe.new
    dictionary = File.read("/usr/share/dict/words")
    completion.populate(dictionary)

    assert_equal 235886, completion.count
  end

  def test_it_can_suggest_words
    skip
    completion = CompleteMe.new
    dictionary = File.read("/usr/share/dict/words")
    completion.populate(dictionary)

    expected = ["pize", "pizza", "pizzeria", "pizzicato", "pizzle"]

    assert_equal expected, completion.suggest("piz")
  end

  def test_that_it_can_suggest_based_on_word_score
    skip
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

    expected = ["pizza", "pizzicato", "piaba", "piacaba", "piacle"]
    assert_equal expected, completion.suggest('pi')
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
    # add assertion

  end

  def test_it_deletes_orphan_nodes
    completion = CompleteMe.new
    dictionary = "try\ntrying\ntryout"
    completion.populate(dictionary)

    # add assertion

  end

  def test_it_deletes_a_word
    completion = CompleteMe.new
    dictionary = "try\ntrying\ntryout"
    completion.populate(dictionary)

    completion.delete_word('trying')

    expected = ["try", "tryout"]
    assert_equal expected, completion.suggest('try')

    completion.delete_word('try')

    expected = ["tryout"]
    assert_equal expected, completion.suggest('try')
  end

  def test_it_can_populate_addresses
    skip
    completion = CompleteMe.new
    relative_path = "./data/addresses"
    absolute_path = File.expand_path(relative_path)
    addresses = File.read(absolute_path)
    completion.populate(addresses)

    assert_equal 313493, completion.count
  end

  def test_it_can_suggest_addresses
    skip
    completion = CompleteMe.new
    relative_path = "./data/addresses"
    absolute_path = File.expand_path(relative_path)
    addresses = File.read(absolute_path)
    completion.populate(addresses)

    expected = ["12344 E Olmsted Dr",
      "1234 E 22nd Ave",
      "1234 E 28th Ave",
      "1234 E Colfax Ave",
      "1234 E Colfax Ave Ste 201"]

    assert_equal expected, completion.suggest("1234")
  end

  def test_that_it_can_suggest_based_on_word_score
    skip
    completion = CompleteMe.new
    relative_path = "./data/addresses"
    absolute_path = File.expand_path(relative_path)
    addresses = File.read(absolute_path)
    completion.populate(addresses)

    completion.select("1234", "1234 E Colfax Ave")
    completion.suggest("1234")

    expected = ["1234 E Colfax Ave",
      "1234 E 22nd Ave",
      "1234 E 28th Ave",
      "1234 E Colfax Ave Ste 201",
      "1234 E Colfax Ave Ste 202"]

    assert_equal expected, completion.suggest("1234")
  end

  def test_that_it_can_suggest_based_on_prefix_score_combination
    skip
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
      "1234 E 28th Ave",
      "1234 E Colfax Ave Ste 201",
      "1234 E Colfax Ave Ste 202"]
    assert_equal expected, completion.suggest('1234')

    expected = ["1234 E 22nd Ave",
      "1234 E 28th Ave",
      "12300 E 55th Ave",
      "12300 E 39th Ave",
      "12300 E 48th Ave"]
    assert_equal expected, completion.suggest('123')
  end

  def test_it_deletes_an_address
    skip
    completion = CompleteMe.new
    relative_path = "./data/addresses"
    absolute_path = File.expand_path(relative_path)
    addresses = File.read(absolute_path)
    completion.populate(addresses)

    expected = ["1234 E 27th Ave", "1234 E 22nd Ave", "1234 E 28th Ave"]
    assert_equal expected, completion.suggest('1234 E 2')

    completion.delete_word('1234 E 22nd Ave')

    expected = ["1234 E 27th Ave", "1234 E 28th Ave"]
    assert_equal expected, completion.suggest('1234 E 2')
  end
end
