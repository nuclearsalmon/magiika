module Magiika::Lang
  record Token,
    _type : Symbol,
    pattern : Regex

  record MatchedToken,
    _type : Symbol,
    value : String,
    position : Lang::Position
end
