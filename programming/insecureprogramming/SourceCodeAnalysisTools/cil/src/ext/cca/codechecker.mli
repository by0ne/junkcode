module P :
  sig
    type doc = Pretty.doc
    val nil : doc
    val ( ++ ) : doc -> doc -> doc
    val text : string -> doc
    val num : int -> doc
    val real : float -> doc
    val chr : char -> doc
    val line : doc
    val leftflush : doc
    val break : doc
    val align : doc
    val unalign : doc
    val mark : doc
    val unmark : doc
    val indent : int -> doc -> doc
    val markup : doc -> doc
    val seq : sep:doc -> doit:('a -> doc) -> elements:'a list -> doc
    val docList : ?sep:doc -> ('a -> doc) -> unit -> 'a list -> doc
    val d_list : string -> (unit -> 'a -> doc) -> unit -> 'a list -> doc
    val docArray : ?sep:doc -> (int -> 'a -> doc) -> unit -> 'a array -> doc
    val docOpt : (unit -> 'a -> doc) -> unit -> 'a option -> doc
    val insert : unit -> doc -> doc
    val dprintf : ('a, unit, doc) format -> 'a
    val fprint : out_channel -> width:int -> doc -> unit
    val sprint : width:int -> doc -> string
    val fprintf : out_channel -> ('a, unit, doc) format -> 'a
    val printf : ('a, unit, doc) format -> 'a
    val eprintf : ('a, unit, doc) format -> 'a
    val gprintf : (doc -> doc) -> ('a, unit, doc) format -> 'a
    val withPrintDepth : int -> (unit -> unit) -> unit
    val printDepth : int ref
    val printIndent : bool ref
    val fastMode : bool ref
    val flushOften : bool ref
    val countNewLines : int ref
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
type malloc_status = {
  var_status : int;
  var_loc : Cil.location;
  var_name : Data.s_lval;
}
val input_wrapper_list : (string * int) list ref
val malloc_wrapper_list : string list ref
class mallocVisitor :
  object
    val current_fun : string ref
    val mallocFnHash : (string, malloc_status) Hashtbl.t
    val mallocHash : (Data.s_lval * string, malloc_status) Hashtbl.t
    val mutable mallocLval : string list
    method private addMalloc :
      Data.s_lval -> string -> int -> Cil.location -> unit
    method addWrappers : string list -> unit
    method getMallocFnHash : (string, malloc_status) Hashtbl.t
    method getMallocHash : (Data.s_lval * string, malloc_status) Hashtbl.t
    method queueInstr : Cil.instr list -> unit
    method removeMalloc : Data.s_lval -> string -> bool
    method summarizeMallocList :
      (Data.s_lhost * Data.s_offset) * string -> malloc_status -> unit
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
class freeVisitor :
  (string, Callgraph.callnode) Hashtbl.t ->
  < removeMalloc : Data.s_lval -> string -> bool; .. > ->
  < getRetHash : (string, Cil.exp option) Hashtbl.t; .. > ->
  object
    val current_formals : Cil.varinfo list ref
    val current_fun : string ref
    val current_locals : Cil.varinfo list ref
    val current_svar : Cil.varinfo ref
    val freeLval : Data.s_lval
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
val staticAnalyzer : Cil.file -> unit
val doCallGraph : bool ref
val parselist : string list -> (string * int) list
val feature : Cil.featureDescr
