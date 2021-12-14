# frozen_string_literal: true

# the main game
class HangmanGame
  def play
    guesses_left = 12
    word = random_word
    guessed_word = Array.new(word.length).map { '_' }
    p word
    turns = 0
    loop do
      # this loop needs to be refactored into like 3 smaller functions lol
      turns += 1
      puts "#{guessed_word.join}, #{guesses_left} guesses left."
      guess = make_guess

      if word.include?(guess)
        guessed_word = word.split('').map.with_index do |char, index|
          char == guess ? char : guessed_word[index]
        end
        if word == guessed_word.join
          puts "You guessed the word: #{word} in #{turns} turns!"
          break
        end
        next
      end

      guesses_left -= 1
      if guesses_left.zero?
        puts "No more guesses left!\nSecret word was #{word}"
        break
      end
    end
  end

  private

  def make_guess
    begin
      system('stty raw -echo')
      $stdin.getc
    ensure
      system('stty -raw echo')
    end
  end

  def random_word
    File.readlines("#{__dir__}/dictionary.txt").sample.to_s.chomp
  end
end
