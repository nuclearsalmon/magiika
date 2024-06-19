require "log"
require "./magiika/magiika_interpreter"

module Magiika::Lang
  PARSER_REFERENCE_RECURSION_LIMIT = 1024

  Log = ::Log.for("lang")
end
