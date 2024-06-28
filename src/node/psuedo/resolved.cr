module Magiika
  # Represents a resolved type.
  #
  # Hard conditions:
  # - `eval` shall return self, or at least the same,
  #   resolved object every time; It is thus generally not
  #   neccessary to call eval.
  #
  # Weak expectations:
  # - Statement nodes are rarely if ever considered resolved.
  # - Types and primitives are almost always considered resolved.
  # - A Scope is not required to use the object itself.
  # - The node is "reasonably" static; meaning it is not
  #   expected to change much, if at all.
  # - The node should not contain other nodes,
  #   unless those also are resolved.
  module Psuedo::Resolved
    #include Node
  end
end
