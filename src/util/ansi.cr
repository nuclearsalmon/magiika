module Magiika::ANSI
  RESET                   = "\x1b[m"

  UNDERLINE_ON            = "\x1b[4m"
  UNDERLINE_OFF           = "\x1b[24m"

  private STX             = "\02"
  private ETX             = "\03"

  # misuses C1 codes to allow underline across spaces

  EXTENDED_UNDERLINE_ON   = UNDERLINE_ON + STX
  EXTENDED_UNDERLINE_OFF  = ETX + UNDERLINE_OFF

  MAGIIKA_STRONG_ACCENT   = "\x1b[38;2;253;134;42;4m"
  MAGIIKA_ACCENT          = "\x1b[38;2;253;134;42;3m"
  MAGIIKA_WARNING         = "\x1b[38;2;235;59;47m"
  MAGIIKA_RELAXED         = "\x1b[38;2;150;178;195m"
end
