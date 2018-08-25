require './test/helper_test'
require './lib/node'

class NodeTest < Minitest::Test

  def test_that_the_node_class_exists
    node = Node.new

    assert_instance_of Node, node
  end

  def test_that_the_node_has_attributes
    node = Node.new

    assert_equal ({}), node.children
    refute node.complete_word
    assert_equal nil, node.value
  end
end
