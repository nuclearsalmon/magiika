require "./version"

require "./util/macros"
require "./util/object_extensions"
require "./util/algo"
require "./util/ansi"

require "./misc/error"
require "./misc/access"
require "./misc/match_result"

require "./node/node"

require "./typing/typing"
require "./typing/type_node"
require "./typing/type_meta"
require "./typing/resolver"
require "./typing/union"

require "./node/psuedo/**"

require "./node/fn/extra"
require "./node/fn/fn"
require "./node/fn/**"

require "./node/primitives/**"

require "./node/meta/desc/desc"
require "./node/meta/meta"

require "./node/cls/cls"
require "./node/cls/cls_inst"

require "./node/stmt/**"

require "./scope/scope"
require "./scope/standalone_scope"
require "./scope/*"

require "./lang/syntax_macros"
require "./lang/syntax/**"
require "./lang/interpreter"
