module Magiika
  class Ast::For < AstBase
    def initialize(
        position : Position?,
        @var_name : ::String,
        @iterable : Ast,
        @body : Ast)
      super(position)
    end

    def eval(scope : Scope) : Object
      nil_t = scope.definition(Object::Nil)
      result : Object = nil_t

      iterable = @iterable.eval(scope)
      elements = case iterable
        when Instance::List
          iterable.value
        when Instance::Range
          int_type = scope.definition(Type::Int)
          iterable.to_array(int_type)
        else
          raise Error::Lazy.new(
            "'for' requires a List or Range, got #{iterable.type_name}.")
        end

      elements.each do |element|
        scope.root_scope.check_resource_limits!

        Scope.use(
          name: "for",
          parent: scope,
          position: @position
        ) do |loop_scope|
          loop_scope.define(@var_name, element)
          begin
            result = @body.eval(loop_scope)
          rescue signal : BreakSignal
            result = signal.value || nil_t
            return result
          rescue NextSignal
            next
          end
        end
      end

      result
    end
  end
end
