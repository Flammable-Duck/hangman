# frozen_string_literal: true

require 'msgpack'

# the main game
class HangmanGame
  def initialize(save = nil, cheat: false)
    if save.nil?
      @word = random_word.freeze
      puts @word if cheat == true
      @guessed_word = Array.new(@word.length).map { '_' }
      @incorrect_letters = []
      @max_incorrect = 6
    end
  end

  def play()
    loop do
      status
      update_guessed_word(make_guess)

      if @incorrect_letters.length == @max_incorrect
        puts "Out of guesses. The word was \"#{@word}\""
        break
      end

      if @word == @guessed_word.join
        puts "You guessed the word \"#{@word}\""
        break
      end
    end
  end

  private

  def update_guessed_word(guess)
    unless @word.split('').include?(guess)
      @incorrect_letters.append(guess)
      puts 'Incorrect!'
    end
    @word.split('').each_with_index do |letter, index|
      @guessed_word[index] = letter if letter == guess && @guessed_word[index] == '_'
    end
  end

  def status
    puts "#{@guessed_word.join} | #{@max_incorrect - @incorrect_letters.length} guesses left"
    puts @incorrect_letters.join(', ')
  end

  def make_guess
    puts 'guess a letter'
    system('stty raw -echo')

    input = $stdin.getc

    if input == ''
      puts 'saving...'
      save
      puts 'quitting...'
      exit
    end
    return input
  ensure
    system('stty -raw echo')
  end

  def save
    {
      word: @word,
      guessed_word: @guessed_word,
      incorrect_letters: @incorrect_letters,
      max_incorrect: @max_incorrect
    }.to_msgpack
  end

  def random_word
    File.readlines("#{__dir__}/dictionary.txt").sample.to_s.chomp
  end
end
