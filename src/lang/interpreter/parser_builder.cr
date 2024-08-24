class Magiika::Interpreter
  private class ParserBuilder < Merlin::ParserBuilder(Symbol, Node)
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

      register_access

      register_define_fn_body
      register_define_fn_params
      register_define_fn

      register_define_cls

      register_define_var

      register_call_fn
      register_chain
    end
  end
end