require "log"


# EXPORT
# ----------------------------------------------------------
require "./magiika/magiika_interpreter.cr"


# LOGGING SETUP
# ----------------------------------------------------------
module Magiika::Lang
  Log = ::Log.for("lang")
end
