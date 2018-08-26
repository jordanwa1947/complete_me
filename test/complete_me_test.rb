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

  def test_it_can_populate
    completion = CompleteMe.new
    dictionary = File.read("/usr/share/dict/words")
    completion.populate(dictionary)

    assert_equal 235886, completion.count
  end

  def test_it_can_generate_suggestions
    completion = CompleteMe.new
    dictionary = File.read("/usr/share/dict/words")
    completion.populate(dictionary)

    expected = ["pize", "pizza", "pizzeria", "pizzicato", "pizzle"]

    assert_equal expected, completion.suggest("piz")
 end

 def test_that_it_can_select_a_word
   completion = CompleteMe.new
   dictionary = File.read("/usr/share/dict/words")
   completion.populate(dictionary)
   completion.suggest('piz')
   completion.select("piz", "pizzeria")
   expected = ["pizzeria", "pize", "pizza", "pizzicato", "pizzle"]

   assert_equal expected, completion.suggest('piz')
 end

end
