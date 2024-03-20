module Magiika::Lang
  record Token, 
    _type : Symbol, 
    pattern : Regex

  record MatchedToken,
    _type : Symbol,
    value : String,
    pos : Lang::Position
end
