module Magiika::Lang
  record Token,
    _type : Symbol,
    pattern : Regex do

    def to_s
      ":#{@_type}(\"#{@value}\")"
    end
  end

  record MatchedToken,
    _type : Symbol,
    value : String,
    position : Position do

    def to_s
      ":#{@_type}(\"#{@value}\") @ #{@position.to_s}"
    end
  end
end
