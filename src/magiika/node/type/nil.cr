module Magiika
  class Node::Nil < NodeClassBase
    private def initialize(position : Lang::Position)
      super(position)
    end

    def self.instance
      @@instance ||= new(Lang::Position.new)
    end

    def to_s
      return "nil"
    end
    
    def self.to_s
      return "nil"
    end

    def eval(scope : Scope) : Node::Nil
      return self
    end

    def self.eval(scope : Scope) : Node::Nil
      return self
    end

    def eval_bool(scope : Scope) : ::Bool
      return false
    end

    def self.eval_bool(scope : Scope) : ::Bool
      return false
    end
  end
end
