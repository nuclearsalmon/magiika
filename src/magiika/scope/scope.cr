module Magiika::Scope
  abstract class Scope
    abstract def get?(ident : Lang::MatchedToken) : Node::Node?
    abstract def get(ident : Lang::MatchedToken) : Node::Node
    abstract def set(ident : Lang::MatchedToken, value : Node::Node) : Nil
    abstract def exist?(ident : Lang::MatchedToken) : ::Bool
    abstract def find_global_scope() : Scope
  end
end
