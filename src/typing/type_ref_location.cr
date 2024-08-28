module Magiika
  record TypeReferenceLocation,
    position : Position? = nil,
    scope : Scope? = nil \
  do
    def to_s : String
      scope = @scope
      position = @position

      if scope.nil? && position.nil?
        "Referenced by unknown"
      else
        ("Referenced " +
         (scope.nil? ? "by scope #{scope.name} " : "") +
         (position.nil? ? "at #{position}" : "") +
         ".")
      end
    end
  end
end
