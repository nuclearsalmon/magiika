require "./position.cr"

require "./util/util.cr"
require "./misc/misc.cr"
require "./typing.cr"

require "./node/node.cr"

#require "./type_node/type_node.cr"
require "./type_node/iface.cr"
require "./type_node/psuedo.cr"
require "./type_node/defaults"
require "./type_node/type_node.cr"

require "./node_implements/members/member_objects_helper.cr"
require "./node_implements/members/shared.cr"

require "./node_implements/fn/supplementary.cr"
require "./node_implements/fn/templates/**"
require "./node_implements/fn/fn.cr"
require "./node_implements/fn/**"

require "./node_implements/psuedo/**"

require "./node_implements/primitives/**"

require "./node_implements/meta/desc/desc.cr"
require "./node_implements/meta/meta.cr"

require "./node_implements/cls/cls.cr"
require "./node_implements/cls/cls_inst.cr"

require "./node_implements/stmt/**"

require "./scope/scope.cr"
require "./scope/**"
