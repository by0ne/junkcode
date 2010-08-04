module P :
  sig
    val fprintf : out_channel -> ('a, out_channel, unit) format -> 'a
    val printf : ('a, out_channel, unit) format -> 'a
    val eprintf : ('a, out_channel, unit) format -> 'a
    val sprintf : ('a, unit, string) format -> 'a
    val bprintf : Buffer.t -> ('a, Buffer.t, unit) format -> 'a
    val kprintf : (string -> 'a) -> ('b, unit, string, 'a) format4 -> 'b
    val scan_format :
      string ->
      int ->
      (string -> int -> 'a) ->
      ('b -> 'c -> int -> 'a) -> ('d -> int -> 'a) -> (int -> 'a) -> 'a
  end
module H :
  sig
    type ('a, 'b) t = ('a, 'b) Hashtbl.t
    val create : int -> ('a, 'b) t
    val clear : ('a, 'b) t -> unit
    val add : ('a, 'b) t -> 'a -> 'b -> unit
    val copy : ('a, 'b) t -> ('a, 'b) t
    val find : ('a, 'b) t -> 'a -> 'b
    val find_all : ('a, 'b) t -> 'a -> 'b list
    val mem : ('a, 'b) t -> 'a -> bool
    val remove : ('a, 'b) t -> 'a -> unit
    val replace : ('a, 'b) t -> 'a -> 'b -> unit
    val iter : ('a -> 'b -> unit) -> ('a, 'b) t -> unit
    val fold : ('a -> 'b -> 'c -> 'c) -> ('a, 'b) t -> 'c -> 'c
    val length : ('a, 'b) t -> int
    module type HashedType =
      sig type t val equal : t -> t -> bool val hash : t -> int end
    module type S =
      sig
        type key
        type 'a t
        val create : int -> 'a t
        val clear : 'a t -> unit
        val copy : 'a t -> 'a t
        val add : 'a t -> key -> 'a -> unit
        val remove : 'a t -> key -> unit
        val find : 'a t -> key -> 'a
        val find_all : 'a t -> key -> 'a list
        val replace : 'a t -> key -> 'a -> unit
        val mem : 'a t -> key -> bool
        val iter : (key -> 'a -> unit) -> 'a t -> unit
        val fold : (key -> 'a -> 'b -> 'b) -> 'a t -> 'b -> 'b
        val length : 'a t -> int
      end
    module Make :
      functor (H : HashedType) ->
        sig
          type key = H.t
          type 'a t = 'a Hashtbl.Make(H).t
          val create : int -> 'a t
          val clear : 'a t -> unit
          val copy : 'a t -> 'a t
          val add : 'a t -> key -> 'a -> unit
          val remove : 'a t -> key -> unit
          val find : 'a t -> key -> 'a
          val find_all : 'a t -> key -> 'a list
          val replace : 'a t -> key -> 'a -> unit
          val mem : 'a t -> key -> bool
          val iter : (key -> 'a -> unit) -> 'a t -> unit
          val fold : (key -> 'a -> 'b -> 'b) -> 'a t -> 'b -> 'b
          val length : 'a t -> int
        end
    val hash : 'a -> int
    external hash_param : int -> int -> 'a -> int = "caml_hash_univ_param"
      "noalloc"
  end
val lvalInExp : Cil.lval -> Cil.exp -> bool
val calcBinOp : 'a -> 'a -> Cil.binop -> bool
exception No_Int_Expr of Cil.exp * bool
val handleBinOp : Cil.binop -> Cil.lval -> Cil.exp -> Cil.exp -> int -> unit
class outOfBoundsVarIndexVisitor :
  Cil.stmt option ->
  'a ->
  < getInitOfVarinfo : Cil.varinfo -> Cil.init option; .. > ->
  < getVarMapLocalsHash : (Cil.lval * 'b, Cil.exp) Hashtbl.t; .. > ->
  'b ->
  object
    val current_block : Cil.block ref
    val is_endless : bool ref
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
class outOfBoundsVisitor :
  < getInitOfVarinfo : Cil.varinfo -> Cil.init option; .. > ->
  < getVarMapLocalsHash : (Cil.lval * string, Cil.exp) Hashtbl.t; .. > ->
  object
    val current_fun : string ref
    val current_var : Cil.varinfo ref
    val scope_var : (Cil.varinfo * int list) ref
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
