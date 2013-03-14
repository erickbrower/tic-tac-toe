require './tic_tac_toe.rb'
 
class DeepBlue

  class << self
    def pick_move(game, my_mark, opponent_mark)
      open_moves = game.open_moves
      next_move = [my_mark, open_moves.sample]
 
      if game.first_move? 
        next_move = [my_mark, [:tl, :tr, :bl, :br].sample]
      elsif game.center_open? 
        next_move = [my_mark, :cc]
      else
        opponent_moves = game.moves_for opponent_mark
        my_moves = game.moves_for my_mark
        opp_win_move = get_winning_move opponent_moves, open_moves
        if opp_win_move.nil?
          my_win_move = get_winning_move my_moves, open_moves
          unless my_win_move.nil?
            next_move = [my_mark, my_win_move]
          end
        else
          next_move = [my_mark, opp_win_move]
        end
      end
      next_move
    end
 
    def get_winning_move(moves, open_moves)
      TicTacToe::WINNING_PATTERNS.each do |pattern| #CHEATER!
        matches = []
        moves.each do |move|
          matches << move if pattern.include? move
          if matches.size >= 2
            next_move = (pattern - matches)[0]
            return next_move if open_moves.include? next_move
            matches = []
          end
        end
      end
      nil
    end
  end
end
