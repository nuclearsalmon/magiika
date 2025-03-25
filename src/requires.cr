require "./version"

require "./constants"

require "./misc/macros"
require "./misc/object_extensions"
require "./misc/algo"
require "./misc/ansi"
require "./misc/error"
require "./misc/match_result"

require "./misc/feat/positionable"
require "./object/object"
require "./object/meta_object"

require "./typing/type_ids"
require "./object/type_constraint"
require "./object/slot"
require "./object/union"

require "./security/access_control"
require "./scope/scope"
require "./scope/global_scope"
require "./scope/class_scope"

require "./misc/feat/**"

require "./ast/ast"

require "./object/function/parameter"
require "./object/function/argument"
require "./object/function/function"
require "./object/function/abstract_function"
require "./object/function/native_function"
require "./object/function/runtime_function"

require "./misc/number"
require "./object/primitives/primitive_object"
require "./object/primitives/*"

require "./object/class/class"
require "./object/class/class_init_method"
require "./object/class/class_instance"

require "./ast/**"

require "./interpreter/syntax_macros"
require "./interpreter/syntax/**"
require "./interpreter/interpreter"
