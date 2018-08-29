# CompleteMe
Everyone in today’s smartphone-saturated world has had their share of interactions with textual “autocomplete.” You may have sometimes even wondered if autocomplete is worth the trouble, given the ridiculous completions it sometimes attempts.

But how would you actually make an autocomplete system?

In this project, CompleteMe, we explore this idea by a simple textual autocomplete system. Perhaps in the process we will develop some sympathy for the developers who built the seemingly incompetent systems on our phones.

## Project Specifications
Click [here](http://backend.turing.io/module1/projects/complete_me) to view the specifications for this project.

## Project Functionality

### GUI Functionality

* Populates the dictionary using the OSX built-in word list.
* Submit a string to get autocomplete suggestions.
* Select a suggested word to display the word's definition (fetched from [Oxford Dictionary](https://developer.oxforddictionaries.com/) API).
* Frequency of word selection is stored in order to move more relevant suggestions to the top of the list.

### Other Functionality (for testing only)
* Populates the dictionary with addresses from the City and County of Denver [website](https://www.denvergov.org/opendata/dataset/city-and-county-of-denver-addresses).
* Add a word to the dictionary.
* Delete a word from the dictionary.

## Installation

1. Clone this repository.

        git clone git@github.com:jordanwa1947/complete_me.git
        
2. Navigate to the project directory and run the tests.

        cd complete_me
        ruby test/complete_me_test.rb

## Run the Tests

1. Clone this repository.

        git clone git@github.com:jordanwa1947/complete_me.git
        
2. Install [Flammarion](https://github.com/zach-capalbo/flammarion).

        gem install flammarion

3. Navigate to the project directory and run the GUI.

        cd complete_me
        ruby gui/gui.rb

Data Sets

* Words are populated using the OSX built-in word list at `/usr/local/dict/words`.
* Addresses were downloaded in CSV format from the City and County of Denver [website](https://www.denvergov.org/opendata/dataset/city-and-county-of-denver-addresses).
* Word definitions are fetched from the [Oxford Dictionary API](https://developer.oxforddictionaries.com/).

## Contributors
* [Jordan Whitten](https://github.com/jordanwa1947)
* [Silvestre Cuellar](https://github.com/SiCuellar)
* [Michael Gatewood](https://github.com/mngatewood)

