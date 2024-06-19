require "./lang/parser/misc/position"

require "./util/util"
require "./misc/misc"
require "./typing"

require "./node/node"

#require "./type_node/type_node"
require "./type_node/iface"
require "./type_node/psuedo"
require "./type_node/defaults"
require "./type_node/type_node"

require "./node_implements/members/member_objects_helper"
require "./node_implements/members/shared"

require "./node_implements/fn/supplementary"
require "./node_implements/fn/templates/**"
require "./node_implements/fn/fn"
require "./node_implements/fn/**"

require "./node_implements/psuedo/**"

require "./node_implements/primitives/**"

require "./node_implements/meta/desc/desc"
require "./node_implements/meta/meta"

require "./node_implements/cls/cls"
require "./node_implements/cls/cls_inst"

require "./node_implements/stmt/**"

require "./scope/scope"
require "./scope/**"
