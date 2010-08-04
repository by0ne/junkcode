type s_lhost = SVar of string | SMem of s_lval
and s_offset = SError | SNoOffset | SField of string
and s_lval = s_lhost * s_offset
val print_s_lval : s_lhost * s_offset -> string
val print_s_lval_struct : s_lhost * s_offset -> string
val getNameOfOffset : Cil.offset -> s_offset
val getNameOfLval : Cil.lhost * Cil.offset -> s_lval
val getNameOfExp : Cil.exp -> s_lval
exception Lval_not_found
val getLvalOfExp : Cil.exp -> Cil.lval
val getVarinfoOfLval : Cil.lval -> Cil.varinfo
val inc : int ref -> unit
val readfile : string -> string list
