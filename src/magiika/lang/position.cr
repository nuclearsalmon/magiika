require "../util/clone_macros"

module Magiika::Lang
  struct Position
    getter filename : String
    getter row : Int32
    getter col : Int32

    Util.def_clone_methods

    @@default_mutex = Mutex.new
    @@default = Position.new

    def self.new
      @@default_mutex.synchronize(-> {
        default = @@default
        if default.nil?
          instance = Position.allocate
          instance.initialize
          default = instance
          instance
        else
          default
        end
      })
    end

    def initialize
      @filename = ""
      @row = -1
      @col = -1
    end

    def initialize(
        @filename : String,
        @row : Int32,
        @col : Int32)
    end
  end
end
