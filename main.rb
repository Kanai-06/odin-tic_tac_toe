require 'bundler/setup'
Bundler.require(:default)

require_relative('lib/player')

class Game # rubocop:disable Style/Documentation
  def start_game
    game_results = Array.new(3) { Array.new(3) { ' ' } }
    players = get_players_array

    player_number = 0
    print_game(game_results)
    until game_finished?(game_results)
      play_round(players[player_number % 2], game_results)

      player_number += 1
    end

    puts ''
    puts 'Game finished'
    puts "\e[1m#{players[(player_number - 1) % 2].name}\e[0m won !"

    players[(player_number - 1) % 2]
  end

  private

  def game_finished?(array)
    array.each do |row|
      return true if !row[0].strip.empty? && row.all?(row[0])
    end

    array.transpose.each do |column|
      return true if !column[0].strip.empty? && column.all?(column[0])
    end

    main_diagonal = (0...array.length).collect { |i| array[i][i] }
    return true if !main_diagonal[0].strip.empty? && main_diagonal.all?(main_diagonal[0])

    secondary_diagonal = (0...array.length).collect { |i| array[i][array.length - 1 - i] }
    return true if !secondary_diagonal[0].strip.empty? && secondary_diagonal.all?(secondary_diagonal[0])

    false
  end

  def get_player(number)
    puts "Type the name of Player #{number}"
    player_name = gets.chomp

    puts "Type the symbol Player #{number} will be using"
    while (player_symbol = gets.chomp).length != 1
      puts 'The symbol must be a single character'
    end

    Player.new(player_name, player_symbol)
  end

  def get_players_array # rubocop:disable Naming/AccessorMethodName
    [get_player(1), get_player(2)]
  end

  def play_round(player, array)
    puts "Turn of \e[1m#{player.name}\e[0m:"
    puts ''
    spot = get_valid_spot(array)
    play_at_spot(player, spot, array)
    print_game(array)
  end

  def print_game(array)
    col_separator = ' | '
    row_separator = '-------+-------+-------'

    puts "\t   #{(1..array.length).to_a.join('       ')}"
    puts ''

    array.each_with_index do |row, index|
      puts "#{index + 1}\t   #{row.join("  #{col_separator}  ")}"
      puts "\t#{row_separator}" unless index == array.length - 1
    end
  end

  def play_at_spot(player, spot, array)
    array[spot[0]][spot[1]] = player.symbol

    array
  end

  def get_valid_spot(array)
    spot = Array.new(2)
    loop do
      puts 'Which row do you want to play at ?'
      row = valid_coordinate_input
      puts 'Which column do you want to play at ?'
      column = valid_coordinate_input

      if spot_available?(row - 1, column - 1, array)
        spot = [row - 1, column - 1]
        break
      else
        puts 'Non-available spot'
      end
    end

    spot
  end

  def valid_coordinate_input
    until (coordinate = gets.chomp.to_i) in (1..3)
      puts 'Coordinate value must be between 1 and 3'
    end

    coordinate
  end

  def spot_available?(row, column, array)
    array[row][column].strip.empty?
  end
end
