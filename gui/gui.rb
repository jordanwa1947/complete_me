require 'flammarion'
require './lib/complete_me'
require 'colorized'
require 'pry'

f = Flammarion::Engraving.new
f.orientation = :vertical
f.title("Complete_Me")
completion = CompleteMe.new
completion.populate(File.read('/usr/share/dict/words'))

def build(instance)
  instance.subpane('button')
end

def pane(instance)
  instance.subpane("main")
end

def suggestion(instance)
  instance.pane("dropdown")
end

def submit(instance)
  instance.subpane("drop")
end

def definition(instance)
  instance.subpane("word_meaning")
end

f.puts"Welcome to Data Finder!"
f.html("<center> <h1> Welcome to Data Finder! </h1> </center>")

input_chars = f.input("Type Something!")

f.button("Find!!!!") do
  suggestion(f).close
  suggestion(f).html("<center><h2>pick a word!</h2><center>")
  suggestion(f).dropdown(completion.suggest(input_chars)) do |word|
    completion.select(input_chars, word["value"])
  definition(f).html("<center><h2>I'm a #{word["value"]} definition!</h2><center>")
  end
end

f.wait_until_closed
