module Magiika::Lang::Syntax
  protected def register_function_call
    group :fn_call do
      rule :members, :PAR do |context|
        target = context[:members].node
        context.clear
        context.add(Node::Call.new(nil, target, FnArgs.new))
      end
    end
  end
end