# frozen_string_literal: true

require 'msgpack'

# the main game
class HangmanGame
  def initialize(save_location = nil)
    @save_location = save_location
    if save_location.nil?
      @word = random_word.freeze
      @guessed_word = Array.new(@word.length).map { '_' }
      @incorrect_letters = []
      @max_incorrect = 12
    else
      save = MessagePack.unpack(File.open(save_location))
      @word = save['word']
      @guessed_word = save['guessed_word']
      @incorrect_letters = save['incorrect_letters']
      @max_incorrect = save['max_incorrect']
    end

    puts @word if ENV['cheat'] == 'true'
  end

  def play
    while lost? == false && won? == false
      status
      update_guessed_word(make_guess)
    end
  end

  private

  def won?
    if @word == @guessed_word.join
      puts "You guessed the word \"#{@word}\""
      File.delete(@save_location.to_s) if File.exist?(@save_location.to_s)
      true
    else
      false
    end
  end

  def lost?
    if @incorrect_letters.length == @max_incorrect
      puts "Out of guesses. The word was \"#{@word}\""
      File.delete(@save_location.to_s) if File.exist?(@save_location.to_s)
      true
    else
      false
    end
  end

  def update_guessed_word(guess)
    unless @word.downcase.split('').include?(guess)
      @incorrect_letters.append(guess) unless @incorrect_letters.include?(guess)
      puts 'Incorrect!'
    end
    @word.split('').each_with_index do |letter, index|
      @guessed_word[index] = letter if letter.downcase == guess && @guessed_word[index] == '_'
    end
  end

  def status
    puts "#{@guessed_word.join} | #{@max_incorrect - @incorrect_letters.length} guesses left"
    puts "incorrect letters: #{@incorrect_letters.join(', ')}"
  end

  def make_guess
    puts 'guess a letter'
    system('stty raw -echo')
    input = $stdin.getc.downcase
    system('stty -raw echo')

    if input == ''
      save
      exit
    end

    input
  end

  def save
    puts 'saving...'
    File.open("#{__dir__}/../saves/save", 'w') do |savefile|
      savefile.write({
        word: @word,
        guessed_word: @guessed_word,
        incorrect_letters: @incorrect_letters,
        max_incorrect: @max_incorrect
      }.to_msgpack)
    end
  end

  def random_word
    File.readlines("#{__dir__}/../data/dictionary.txt").sample.to_s.chomp
  end
end
