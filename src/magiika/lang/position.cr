require "../util/clone_macros"

module Magiika::Lang
  struct Position
    getter filename : String?
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

    def self.default
      self.new
    end

    def initialize
      @row = -1
      @col = -1
      @filename = nil
    end

    def initialize(
        @row : Int32,
        @col : Int32,
        @filename : String? = nil)
    end

    def to_s
      filename = @filename
      if filename.nil? || filename == ""
        "<Row #{ @row }, Column #{ @col }>"
      else
        "<(Row #{ @row }, Column #{ @col }) in \"#{ filename }\">"
      end
    end
  end
end
