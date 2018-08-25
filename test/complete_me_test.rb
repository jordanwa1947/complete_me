require './test/helper_test'
require './lib/complete_me'
require './lib/node'

class CompleteMeTest < Minitest::Test

  def test_that_the_complete_me_class_exists
    complete_me = CompleteMe.new

    assert_instance_of CompleteMe, complete_me
  end

  def test_that_complete_me_can_insert_a_word
    complete_me = CompleteMe.new
    complete_me.insert('pizza')

    assert_equal 1, complete_me.count
  end
end
