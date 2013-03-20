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


#only pawn has valid_take_vector, if valid_take_vector is nil, we use the valid_move_vectors

class Piece
  attr_reader :valid_move_vectors, :vector_multiple, :color
  def initialize(color)
    @color = color
    @has_moved = false
    @direction = @color == :white ? 1 : -1
    @vector_multiple = 1
  end
end

class Knight < Piece
  def initialize(color)
    super(color)
    @valid_move_vectors = [[2,1],[1,2],[-2,1],[-1,2],[2,-1],[1,-2],[-2,-1],[-1,-2]]
    @vector_multiple = 1
  end
# valid move vector => vectors and vector multiples
end

class Bishop < Piece
  def initialize(color)
    super(color)
    @valid_move_vectors = [[1,1],[1,-1],[-1,1],[-1,1]]
    @vector_multiple = 100
  end
# valid move vector
end

class Queen < Piece
  def initialize(color)
    super(color)
    @valid_move_vectors = [[1,1],[1,-1],[-1,1],[-1,1],[1,0],[-1,0],[0,1],[0,-1]]
    @vector_multiple = 100
  end
# valid move vector
end

class Pawn < Piece
  attr_reader :valid_take_vector
  def initialize(color)
    super(color)
    @valid_move_vectors = (color == :black) ? [[1,0]] : [[-1,0]]
    @vector_multiple = @move_taken ? 1 : 2 # REV when do you toggle this first move flag?
    @valid_take_vector = (color == :black) ? [[1,1],[1,-1]] : [[-1,1],[-1,-1]]
  end
end

class King < Piece
  def initialize(color)
    super(color)
    @valid_move_vectors = [[1,1],[1,-1],[-1,1],[-1,1],[1,0],[-1,0],[0,1],[0,-1]]
    @vector_multiple = 1
  end
end

class Castle < Piece
  def initialize(color)
    super(color)
    @valid_move_vectors = [[1,0],[0,-1],[-1,0],[0,1]]
    @vector_multiple = 100
  end
end

class HumanPlayer
# displays user prompts and gets user input

  attr_reader :color

  def initialize(color)
    @color = color
  end

  def prompt_start_move
    start_space = nil
    until start_space
      puts "Select the square of the piece you would like to move from."
      start_space = translate(gets.chomp)
    end
    start_space
  end

  def prompt_end_move
    end_space = nil
    until end_space
      puts "Select the square of the piece you would like to move to."
      end_space = translate(gets.chomp)
    end
    end_space
  end

  def translate(string)
    # E4 => 5,3
    letter, number = string.scan(/[a-h]/)[0], string.scan(/[1-8]/)[0]
    unless letter && number
      puts "That is not a valid square"
      return nil
    end
    [(8 - number.to_i), (letter.ord - "a".ord) ]
  end
end

class Board
  attr_reader :board

  def initialize
    @dimension = 8
    @board = Array.new(8) { Array.new(8) }
    @dead_pieces = []
    setup
  end

  def color(position)
    color = position[0] < 3 ? :black : :white
  end

  def setup
    castle_start = [[0,0],[0,7],[7,0],[7,7]]
    knight_start = [[0,1],[0,6],[7,1],[7,6]]
    bishop_start = [[0,2],[0,5],[7,2],[7,5]]
    king_start,queen_start = [[0,3],[7,3]],[[0,4],[7,4]]
    pawn_start = []
    8.times {|i| pawn_start << [1,i] ; pawn_start << [6,i] }

    castle_start.each {|pos| @board[pos[0]][pos[1]] = Castle.new(color(pos))}
    knight_start.each {|pos| @board[pos[0]][pos[1]] = Knight.new(color(pos))}
    bishop_start.each {|pos| @board[pos[0]][pos[1]] = Bishop.new(color(pos))}
    king_start.each {|pos| @board[pos[0]][pos[1]] = King.new(color(pos))}
    queen_start.each {|pos| @board[pos[0]][pos[1]] = Queen.new(color(pos))}
    pawn_start.each {|pos| @board[pos[0]][pos[1]] = Pawn.new(color(pos))}
  end

  def valid_moves_in_direction(vector, position)
    possible_moves = []
    piece(position).vector_multiple.times do |i|
      new_position = [position[0] + vector[0] * (i + 1),
      position[1] + vector[1] * (i + 1)]
      break unless is_on_board(new_position)
      if piece(new_position)
          unless piece(position).color == piece(new_position).color
            possible_moves << new_position
          end
          return possible_moves
      end
      possible_moves << new_position
    end
    possible_moves
  end


  def possible_moves(position)
    possible_moves = []
    piece(position).valid_move_vectors.each do |vector|
      possible_moves += valid_moves_in_direction(vector, position)
    end
    possible_moves
  end

  def is_on_board(position)
    position[0] <= 7 && position[0] >= 0 && position[1] <= 7 && position[1] >= 0
  end # REV You can use between? here to save some space.

  def make_move(start_position, end_position)
    if possible_moves(start_position).include?(end_position)
      #false if @board.check(start_position, end_position)
      place_piece(start_position, end_position, @board)
      true
    else
      false
    end
  end

  def place_piece(start_position, end_position, board)
    piece_mover = board[start_position[0]][start_position[1]]
    board[start_position[0]][start_position[1]] = nil
    @dead_pieces << piece(end_position) if piece(end_position)
    board[end_position[0]][end_position[1]] = piece_mover
  end

  def dup
    @board.map(&:dup)
  end

  def check(start_position, end_position)
    shadow_board = @board.dup
    color = piece(start_position).color
    king_position = kingfinder(color, shadow_board)
    place_piece(start_position, end_position, shadow_board)
  end

  def kingfinder(color, board)
    board.each_with_index do |row, r_index|
      row.each_with_index do |space, c_index|
        if space.class.to_s == "King" && space.color == color
          return [r_index, c_index]
        end
      end
    end
  end

  def display
    dup.each do |row|
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
           "     *     "
        end
      end
      puts "|"
    end
    nil
  end

  def piece(position)
    @board[position[0]][position[1]]
  end

end

class Chess
  def initialize
    @board = Board.new
    @players = [HumanPlayer.new(:white),HumanPlayer.new(:black)]
  end

  def check_start_move_color(turn_taking_player, position)
    @board.piece(position).color == turn_taking_player.color
  end

  def play
    until false
      turn_taking_player = @players[0]
      start_valid = false; piece = nil
      # grab_piece move
      until start_valid && piece
        puts "#{turn_taking_player.color}'s move!"
        @board.display
        start_move_position = turn_taking_player.prompt_start_move
        piece = @board.piece(start_move_position)
        if piece
          start_valid = check_start_move_color(turn_taking_player, start_move_position)
        end
      end
      p piece.inspect
      # make_move loop should be put into new loop
      end_valid = false
      until end_valid
        end_move_position = turn_taking_player.prompt_end_move
        end_valid = @board.make_move(start_move_position, end_move_position)
        if end_valid == false
          puts "Invalid move - put in new position to put piece into."
        end
      end
      @players.reverse!
    end
  end
# calls on Player for moves and on Board to make the moves actually happen
# in a loop until win
end
