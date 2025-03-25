class Magiika::Scope::Global < Magiika::Scope
  def initialize(
    position : Position,
    variables : Hash(::String, Object::Slot) = Hash(::String, Object::Slot).new,
  )
    super(
      name: "global",
      position: position,
      parent: nil,
      variables: variables)
  end
end
