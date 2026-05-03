require "./version"

require "./constants"

require "./misc/feat/is_of"
require "./misc/crystal_utils"
alias Magiika::U = CrystalUtils
require "./misc/util"

require "./misc/algo"
require "./misc/ansi"
require "./misc/error"
require "./misc/control_signal"
require "./misc/match_result"

require "./misc/feat/positionable"
require "./object/object"
require "./object/type"
require "./object/type_deferred"
require "./object/type_generic"
require "./object/instance"
require "./object/type_singleton"
require "./ast/ast"
require "./object/primitives/number"
require "./object/primitives/*"

require "./typing/type_ids"
require "./object/misc/type_constraint"
require "./object/primitives/slot"
require "./object/misc/union"

require "./security/access_control"
require "./security/resource_limits"
require "./security/security_visibility"
require "./security/security_config"
require "./scope/scope"
require "./scope/global_scope"
require "./scope/class_scope"

require "./misc/feat/**"

require "./object/function/parameter"
require "./object/function/argument"
require "./object/function/function"
require "./object/function/abstract_function"
require "./object/function/native_function"
require "./object/function/runtime_function"

require "./object/class/class"
require "./object/class/class_init_method"
require "./object/class/class_instance"

require "./security/security_info_type"

require "./ast/**"

require "./interpreter/syntax_macros"
require "./interpreter/syntax/**"
require "./interpreter/interpreter"
