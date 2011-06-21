class userInputTraceVisitor :
  object
    val mutable inputFns : (string * int) list
    method addWrappers : (string * int) list -> unit
    method queueInstr : Cil.instr list -> unit
    method unqueueInstr : unit -> Cil.instr list
    method vattr : Cil.attribute -> Cil.attribute list Cil.visitAction
    method vattrparam : Cil.attrparam -> Cil.attrparam Cil.visitAction
    method vblock : Cil.block -> Cil.block Cil.visitAction
    method vexpr : Cil.exp -> Cil.exp Cil.visitAction
    method vfunc : Cil.fundec -> Cil.fundec Cil.visitAction
    method vglob : Cil.global -> Cil.global list Cil.visitAction
    method vinit : Cil.init -> Cil.init Cil.visitAction
    method vinitoffs : Cil.offset -> Cil.offset Cil.visitAction
    method vinst : Cil.instr -> Cil.instr list Cil.visitAction
    method vlval : Cil.lval -> Cil.lval Cil.visitAction
    method voffs : Cil.offset -> Cil.offset Cil.visitAction
    method vstmt : Cil.stmt -> Cil.stmt Cil.visitAction
    method vtype : Cil.typ -> Cil.typ Cil.visitAction
    method vvdec : Cil.varinfo -> Cil.varinfo Cil.visitAction
    method vvrbl : Cil.varinfo -> Cil.varinfo Cil.visitAction
  end
class spreadTaintedInputHelper :
  (string, Callgraph.callnode) Hashtbl.t ->
  < getRetHash : (string, Cil.exp option) Hashtbl.t; .. > ->
  object
    method queueInstr : Cil.instr list -> unit
    method unqueueInstr : unit -> Cil.instr list
    method vattr : Cil.attribute -> Cil.attribute list Cil.visitAction
    method vattrparam : Cil.attrparam -> Cil.attrparam Cil.visitAction
    method vblock : Cil.block -> Cil.block Cil.visitAction
    method vexpr : Cil.exp -> Cil.exp Cil.visitAction
    method vfunc : Cil.fundec -> Cil.fundec Cil.visitAction
    method vglob : Cil.global -> Cil.global list Cil.visitAction
    method vinit : Cil.init -> Cil.init Cil.visitAction
    method vinitoffs : Cil.offset -> Cil.offset Cil.visitAction
    method vinst : Cil.instr -> Cil.instr list Cil.visitAction
    method vlval : Cil.lval -> Cil.lval Cil.visitAction
    method voffs : Cil.offset -> Cil.offset Cil.visitAction
    method vstmt : Cil.stmt -> Cil.stmt Cil.visitAction
    method vtype : Cil.typ -> Cil.typ Cil.visitAction
    method vvdec : Cil.varinfo -> Cil.varinfo Cil.visitAction
    method vvrbl : Cil.varinfo -> Cil.varinfo Cil.visitAction
  end
