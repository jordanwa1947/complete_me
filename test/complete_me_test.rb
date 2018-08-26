require './test/helper_test'
require './lib/complete_me'
require './lib/node'

class CompleteMeTest < Minitest::Test

  def test_that_the_complete_me_class_exists
    complete_me = CompleteMe.new

    assert_instance_of CompleteMe, complete_me
  end

  def test_it_can_count
    complete_me = CompleteMe.new
    complete_me.insert('pizza')
    complete_me.insert('hello')

    assert_equal 2, complete_me.count
  end

  def test_it_can_create_root_node
    complete_me = CompleteMe.new

    assert_equal ({}), complete_me.root.children
    assert_instance_of Node, complete_me.root
  end

  def test_it_can_add_single_character
    complete_me = CompleteMe.new
    complete_me.insert("s")

    assert_equal "s", complete_me.root.children["s"].value
  end

  def test_it_can_add_a_single_word
    complete_me = CompleteMe.new
    complete_me.insert('pizza')

    p_node = complete_me.root.children["p"]
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
    complete_me = CompleteMe.new
    dictionary = File.read("/usr/share/dict/words")
    complete_me.populate(dictionary)

    assert_equal 235886, complete_me.count
  end

  def test_it_can_generate_suggestions

    complete_me = CompleteMe.new
    dictionary = File.read("/usr/share/dict/words")
    complete_me.populate(dictionary)
    
    expected = ["pize", "pizza", "pizzeria", "pizzicato", "pizzle"]

    assert_equal expected, complete_me.suggest("piz")
 end
end
