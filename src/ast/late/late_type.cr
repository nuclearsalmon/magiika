module Magiika
  class Ast::LateType < AstBase
    @type_name : ::String
    @type : Type? = nil
    @mutex = Mutex.new

    def initialize(
      @type_name : ::String,
      position : Position
    )
      super(position)
    end

    def eval(scope : Scope) : Type
      @mutex.synchronize do
        unless (type = @type).nil?
          type
        else
          @type = scope.definition(@type_name)
        end
      end
    end
  end
end
