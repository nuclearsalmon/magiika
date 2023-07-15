module Magiika::Lang
  struct Position
    property filename, row, col

    def initialize(@filename : String, @row : Int32, @col : Int32)
    end
  end
end
