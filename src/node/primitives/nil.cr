module Magiika
  class Node::Nil < TypeNode
    extend SelfEvalType

    private def initialize
      super(nil)
    end

    def self.instance
      @@instance ||= new
    end

    def to_s : String
      type_name
    end

    def to_s_internal : String
      type_name
    end

    def self.to_s : String
      type_name
    end

    def self.to_s_internal : String
      type_name
    end

    def eval(scope : Scope) : self
      return self
    end

    def eval_bool(scope : Scope) : ::Bool
      return false
    end
  end
end
