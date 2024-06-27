class Magiika::Interpreter
  private class ParserBuilder < Merlin::ParserBuilder(Symbol, Psuedo::Node)
    include Syntax

    def initialize
      super

      register_tokens
      register_root
      register_commons
      register_if_else
      register_primitives
      register_expressions
      register_conditions
      register_function_defining
      register_function_call
      register_variables
      register_chaining
      register_class_defining
    end
  end
end