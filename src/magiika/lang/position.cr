module Magiika::Lang
  struct Position
    getter filename : String
    getter row : Int32
    getter col : Int32

    Util.def_clone_methods

    def initialize
      @filename = ""
      @row = -1
      @col = -1
    end

    def initialize(@filename : String, @row : Int32, @col : Int32)
    end
  end
end
