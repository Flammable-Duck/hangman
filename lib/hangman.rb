# frozen_string_literal: true

# the main game
class HangmanGame
  def initialize
    @word = random_word
    @guessed_word = Array.new(@word.length).map { '_' }
    @guesses_left = 12
    @turns = 0
  end

  def play
    p @word
    loop do
      @turns += 1
      puts "#{@guessed_word.join}, #{@guesses_left} guesses left."

      @guessed_word = update_guessed_word(make_guess)

      if @word == @guessed_word.join
        puts "You guessed the word: #{@word} in #{@turns} turns!"
        break
      end

      @guesses_left -= 1
      if @guesses_left.zero?
        puts "No more guesses left!\nSecret word was #{@word}"
        break
      end
    end
  end

  private

  def update_guessed_word(letter)
    return @guessed_word unless @word.downcase.include?(letter.downcase)

    @word.split('').map.with_index do |char, index|
      char.downcase == letter.downcase ? char : @guessed_word[index]
    end
  end

  def make_guess
    system('stty raw -echo')
    $stdin.getc
  ensure
    system('stty -raw echo')
  end

  def random_word
    File.readlines("#{__dir__}/dictionary.txt").sample.to_s.chomp
  end
end
