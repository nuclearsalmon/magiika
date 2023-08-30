module Magiika::Lang::Syntax
  #extend self
  
  protected def register_var
    group(:setvar) do
      rule(:DEFINE, :NAME, :ASSIGN, :value) do \
        |(df,name,op),(value)|
        type(value, Node::Node)

        Magiika::Node::Assign.new(df.pos, name, value)
      end
    end

    group(:getvar) do
      rule(:NAME) do |(name),_|
        Magiika::Node::Retrieve.new(name.pos, name)
      end
    end
  end
end
