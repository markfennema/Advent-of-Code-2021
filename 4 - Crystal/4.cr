require "spec"
puts "Hello World!"

# The correct solution to this problem is to mark up the bingo cards as you go and reduce the runtime from O(MN^2) ->O(MN
# But that would have made the code way less fun (either by adding mutation or forcing me to make a nasty immutable
# clone without one cell function). The BingoBoard class and tests turned out fine but I really was not enjoying Crystal so 
# by the time I was writing up the actual p1/p2 functions I was getting a bit bored and just kludged them together.

class BingoBoard
    @board : Array(Array(Int32))
    def initialize(board_lines : Array(String))
        @board = board_lines.map { |str_line| str_line.strip.split(/\s+/).map { |str_num| str_num.to_i()}}
    end

    def rows()
        return @board
    end

    def columns()
        return @board.transpose
    end

    def validate(winning_numbers)
        options = self.rows() + self.columns()
        return options.any? { |option_nums| option_nums.all? {|num| winning_numbers.includes?(num)}}
    end

    def leftover_numbers(winning_numbers)
        rows.flatten.select { |num| !winning_numbers.includes?(num)}
    end
end

def p1() 
    lines = File.read_lines("input.txt")
    upcoming_winning_numbers = lines[0].split(",").map { |str_num| str_num.to_i }
    number_boards = ((lines.size - 1) / 6).floor
    boards = (0...number_boards).map { |index| BingoBoard.new lines[index*6 + 2 ... index*6 + 7]}

    (1...upcoming_winning_numbers.size).find { |winning_index|
        winning_numbers = upcoming_winning_numbers.first(winning_index)
        winning_board = boards.find { |board| board.validate(winning_numbers)}
        if (!winning_board.nil?) 
            puts winning_board.rows
            puts winning_numbers
            puts winning_board.leftover_numbers(winning_numbers).sum * winning_numbers.last
            return
        end
    }
end
def p2() 
    lines = File.read_lines("input.txt")
    upcoming_winning_numbers = lines[0].split(",").map { |str_num| str_num.to_i }
    number_boards = ((lines.size - 1) / 6).floor
    boards = (0...number_boards).map { |index| BingoBoard.new lines[index*6 + 2 ... index*6 + 7]}

    previous_loser = nil
    (1...upcoming_winning_numbers.size).find { |winning_index|
        winning_numbers = upcoming_winning_numbers.first(winning_index)
        losing_board = boards.find { |board| !board.validate(winning_numbers)}
        if (losing_board.nil?) 
            if (previous_loser.nil?)
                puts "Error, nobody ever "
                return
            end
            puts previous_loser.rows
            puts previous_loser.leftover_numbers(winning_numbers).sum * winning_numbers.last
            return
        end
        previous_loser = losing_board
        puts 
    }
end

p1()
p2()


describe BingoBoard do
    describe "Constructs" do
        board = BingoBoard.new [
            "57 19 40 54 64",
            "22 69 15 88  8",
            "79 60 48 95 85",
            "34 97 33  1 55",
            "72 82 29 90 84"
        ]

        board.rows[0].should eq([57, 19, 40, 54, 64])
    end

    describe "Calculates columns" do
        board = BingoBoard.new [
            "57 19 40 54 64",
            "22 69 15 88  8",
            "79 60 48 95 85",
            "34 97 33  1 55",
            "72 82 29 90 84"
        ]

        board.columns[1].should eq([19, 69, 60, 97, 82])
    end

    describe "Validates rows" do
        board = BingoBoard.new [
            "57 19 40 54 64",
            "22 69 15 88  8",
            "79 60 48 95 85",
            "34 97 33  1 55",
            "72 82 29 90 84"
        ]

        board.validate([22, 15, 8, 88, 69]).should eq(true)
    end

    describe "Validates columns" do
        board = BingoBoard.new [
            "57 19 40 54 64",
            "22 69 15 88  8",
            "79 60 48 95 85",
            "34 97 33  1 55",
            "72 82 29 90 84"
        ]

        board.validate([29, 22, 40, 15, 48, 8, 33, 88, 69]).should eq(true)
    end

    describe "Validates nothing" do
        board = BingoBoard.new [
            "57 19 40 54 64",
            "22 69 15 88  8",
            "79 60 48 95 85",
            "34 97 33  1 55",
            "72 82 29 90 84"
        ]

        board.validate([22, 15, 8, 0, 69]).should eq(false)
    end

    describe "Determines leftover numbers" do
        board = BingoBoard.new [
            "57 19 40 54 64",
            "22 69 15 88  8",
            "79 60 48 95 85",
            "34 97 33  1 55",
            "72 82 29 90 84"
        ]

        board.leftover_numbers([22, 15, 8, 0, 69]).should eq([57, 19, 40, 54, 64, 88, 79, 60, 48, 95, 85, 34, 97, 33, 1, 55, 72, 82, 29, 90, 84])
    end
end