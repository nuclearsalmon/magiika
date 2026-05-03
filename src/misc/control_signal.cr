module Magiika
  class BreakSignal < Exception
    getter value : Object?
    def initialize(@value : Object? = nil); end
  end

  class NextSignal < Exception
    def initialize; end
  end
end
