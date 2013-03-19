# Write a chess game in an object-oriented way.
#
# There are many different kinds of pieces in chess, and each moves a specific way. How will you organize all of these different ways to move?
#
# A valid move also should not leave your king in check. Should the code to check this be in every one of your piece classes? Likewise, pawns can move diagonally to capture pieces (if present); how will you make them aware of other pieces on the board?
#
# You'll have to write logic that determines whether the game is won.
#
# Some kind of Game class should keep track of who's move it is, as well as the board, etc.
#
# You should not "bake in" the logic to prompt for a move into the game class; those concerns should be separated. You will want to write a HumanPlayer class. Don't implement a ComputerPlayer, but your design should allow that to be easily added at a later date.
#
# Note: Do not concern yourself with tricky moves like "en passant". Likewise, don't implement castling, draws, or pawn promotion; if you finish early work on other things. You should handle check and check mate, however.

#Chess


#only pawn has valid_take_vector, if valid_take_vector is nil, we use the valid_move_vector

class Piece
  attr_reader :valid_move_vector, :color
  def initialize(color)
    @color = color
    @in_play = true
    @has_moved = false
    @direction = @color == :white ? 1 : -1
    @vector_multiple = 1
  end
end

class Knight < Piece
  def initialize(color)
    super(color)
    @valid_move_vector = [[2,1],[1,2],[-2,1],[-1,2],[2,-1],[1,-2],[-2,-1],[-1,-2]]
    @vector_multiple = 1
  end
# valid move vector => vectors and vector multiples
end

class Bishop < Piece
  def initialize(color)
    super(color)
    @valid_move_vector = [[1,1],[1,-1],[-1,1],[-1,1]]
    @vector_multiple = 100
  end
# valid move vector
end

class Queen < Piece
  def initialize(color)
    super(color)
    @valid_move_vector = [[1,1],[1,-1],[-1,1],[-1,1],[1,0],[-1,0],[0,1],[0,-1]]
    @vector_multiple = 100
  end
# valid move vector
end

class Pawn < Piece
  attr_reader :valid_take_vector
  def initialize(color)
    super(color)
    @valid_move_vector = [[0,1]]
    @vector_multiple = @move_taken ? 1 : 2
    @valid_take_vector = [[1,1],[-1,1]]
  end
end

class King < Piece
# valid move vector
end

class Castle < Piece
# valid move vector
end

class HumanPlayer
# displays user prompts and gets user input
  def initialize(color)
    @color = color
  end

  def prompt_moves
    puts "Select the square of the piece you would like to move."
  end
end

class Board
  attr_reader :board

  def initialize
    @dimension = 8
    @board = Array.new(8) { Array.new(8) }
    setup
  end

  def color(position)
    color = position[1] < 3 ? :white : :black
  end

  def setup
    castle_start = [[0,7],[7,7],[0,0],[7,0]]
    knight_start = [[1,7],[6,7],[1,0],[6,0]]
    bishop_start = [[2,7],[5,7],[2,0],[5,0]]
    king_start,queen_start = [[3,7],[3,0]],[[4,7],[4,0]]
    pawn_start = []
    8.times {|i| pawn_start << [i,6] ; pawn_start << [i,1] }

    castle_start.each {|pos| @board[pos[0]][pos[1]] = Castle.new(color(pos))}
    knight_start.each {|pos| @board[pos[0]][pos[1]] = Knight.new(color(pos))}
    bishop_start.each {|pos| @board[pos[0]][pos[1]] = Bishop.new(color(pos))}
    king_start.each {|pos| @board[pos[0]][pos[1]] = King.new(color(pos))}
    queen_start.each {|pos| @board[pos[0]][pos[1]] = Queen.new(color(pos))}
    pawn_start.each {|pos| @board[pos[0]][pos[1]] = Pawn.new(color(pos))}
  end

  def dup
    @board.map(&:dup)
  end

  def display
    dup.transpose.each do |row|
      row.each do |space|
        print "|"
        print case space.class.to_s
        when "King"
           " K(#{space.color})  "
        when "Queen"
           " Q(#{space.color})  "
        when "Bishop"
           " B(#{space.color})  "
        when "Knight"
           " Kn(#{space.color}) "
        when "Castle"
           " C(#{space.color})  "
        when "Pawn"
           " P(#{space.color})  "
        when "NilClass"
           " *  "
        end
      end
      puts "|"
    end
    nil
  end

# keeps track of turns and makes moves
# determines game state and legal moves
# checks if player move is in legal move set for given piece
## generated through shadow boards that are deep-duped from current board
# checks for wins
## check if checkmate =>
# knows where are all pieces are
# knows which pieces are in taken set
end

class Chess
# calls on Player for moves and on Board to make the moves actually happen
# in a loop until win
end