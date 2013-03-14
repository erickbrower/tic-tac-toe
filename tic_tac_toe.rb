require './board.rb'

class TicTacToe
  attr_reader :board
 
  WINNING_PATTERNS = [
    [:tl, :cc, :br], 
    [:tc, :cc, :bc],
    [:tr, :cc, :bl],
    [:cl, :cc, :cr],
    [:tl, :tc, :tr],
    [:bl, :bc, :br],
    [:tl, :cl, :bl],
    [:tr, :cr, :br]
  ]
 
  def initialize
    @board = Board.new
  end
  
  def take_turn!(mark, space)
    @board[space] = mark
  end
 
  def winner?
    winner = 'CAT' if occupied_spaces.size == 9
    winner = Board::X_MARK if has_winning_pattern? x_moves
    winner = Board::O_MARK if has_winning_pattern? o_moves
    winner
  end

  def first_move?
    open_moves.size == 9
  end

  def x_moves 
    moves_for Board::X_MARK
  end

  def o_moves
    moves_for Board::O_MARK
  end

  def moves_for(mark)
    board.select { |_, v| v == mark }.keys if mark == Board::O_MARK or mark == Board::X_MARK
  end

  def open_moves
    board.select { |_, v| v == Board::EMPTY_MARK }.keys
  end

  def occupied_spaces
    board.select { |_, v| v != Board::EMPTY_MARK }.keys
  end

  def center_open?
    open_moves.include? :cc
  end

  def opponent_mark(mark)
    case mark
    when Board::X_MARK then Board::O_MARK
    when Board::O_MARK then Board::X_MARK
    else nil
    end
  end
  
  alias_method :winner, :winner?
 
  private
  def has_winning_pattern?(moves)
    WINNING_PATTERNS.each do |pattern|
      matches = 0
      moves.each do |move|
        matches += 1 if pattern.include? move
        return true if matches == 3
      end
    end
    false
  end
end
