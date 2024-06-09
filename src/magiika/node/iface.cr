module Magiika
  module Node::InstanceIface
    # ⭐ Positionality

    abstract def position? : Position?
    abstract def position : Position
    abstract def position! : Position


    # ⭐ Evaluation

    abstract def eval(scope : Scope) : Psuedo::Node
    abstract def eval_bool(scope : Scope) : ::Bool


    # ⭐ String representation

    abstract def type_name : ::String
    abstract def to_s : ::String
    abstract def to_s_internal : ::String
  end

  module Node::ClassIface
    # ⭐ String representation

    abstract def type_name : ::String
    abstract def to_s : ::String
    abstract def to_s_internal : ::String
  end
end
