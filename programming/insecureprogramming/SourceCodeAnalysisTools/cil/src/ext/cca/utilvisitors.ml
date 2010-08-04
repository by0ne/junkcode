(*
Copyright (c) 2004-2005,
 Jonathan Heusser    <jonny@drugphish.ch>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

3. The names of the contributors may not be used to endorse or promote
products derived from this software without specific prior written
permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
*)
(* contains utility visitors *)
open Cil
open Callgraph
open Printf
open Data
open Logger


(* keeps track of the return values of every function in the file *)
class returnVarVisitor = object(self)
  inherit nopCilVisitor

  val current_fun = ref ""
  val ret_name = ref None
  
  (*val retHash:(string, s_lval option) Hashtbl.t = Hashtbl.create 5*)
  val retHash:(string, Cil.exp option) Hashtbl.t = Hashtbl.create 5

  method getRetHash = retHash

  method private addRet fn var =
    Hashtbl.add retHash fn var

  method vfunc (f:fundec) =
  begin
    current_fun := f.svar.vname;
    DoChildren
  end

  method vstmt (s:stmt) =
  begin
    match s.skind with
    (*Return(Some(e),loc) -> self#addRet !current_fun (Some (getNameOfExp e)); DoChildren*)
    Return(Some(e),loc) -> self#addRet !current_fun (Some (e)); DoChildren
    |Return(None,loc) -> self#addRet !current_fun None; DoChildren
    | _ -> DoChildren
  end
end


(* creates a hashtables where all the formals/locals of a function which get modified *)
(* in that function get an entry in the hashtable. This visitor is needed for  *)
(* the null pointer detection and oob detection *)
class varMapVisitor = object(self)
  inherit nopCilVisitor

  val current_fun = ref ""
  val current_formals = ref []
  val current_locals = ref []
  val varMapFormalsHash:(Cil.lval*string, location) Hashtbl.t = Hashtbl.create 2;
  val varMapLocalsHash:(Cil.lval*string, exp) Hashtbl.t = Hashtbl.create 2;

  method getVarMapFormalsHash = varMapFormalsHash
  method getVarMapLocalsHash = varMapLocalsHash

  method vfunc (f:fundec) =
  begin
        current_fun := f.svar.vname;
        current_formals := f.sformals;
        current_locals := f.slocals;
        DoChildren
  end

  (* check if !current_formals get modified *)
  (* e.g. with 'p = x' when p is in the formals *)
  method vinst (i:instr) =
  begin
    match i with
     (* XXX: check that exp is non NULL before adding! *)
     (* XXX: check for pointers!! *)
     Set (lvalue, exp, loc) ->
       (* locals *)
       (*ignore (Errormsg.log "considering: %a\n" d_lval lvalue);*)

       (* we are only interested in simple lvalues used as array indices *)
       begin
       try
       if List.mem (getVarinfoOfLval lvalue) !current_locals then
         Hashtbl.add varMapLocalsHash (lvalue,!current_fun) exp;
      
       (* formals *)
       if !current_fun="main" then
         Hashtbl.add varMapFormalsHash (lvalue,!current_fun) loc
       else begin
        if List.mem (getVarinfoOfLval lvalue) !current_formals then
          Hashtbl.add varMapFormalsHash (lvalue,!current_fun) loc
       end;
       DoChildren

       with _ -> (); DoChildren
       end

     | _ -> DoChildren
  end

end

(* checks if var gets modified *)
class checkForModification var = object(self)
  inherit nopCilVisitor

  val gets_modified = ref false

  method isModified = !gets_modified

  method vinst (i:instr) =
  begin
        junkmsg "checkForModification called\n";
        match i with
        (* Set lval exp loc *)
        Set (lvalue, _, _) ->
          ignore(Errormsg.log "checking if %a equals %a\n" d_lval lvalue d_lval var);
          if var=lvalue then 
                gets_modified := true; DoChildren
        | _ -> DoChildren
  end
end


(*------------------------------------------------------------------*)
(* helper class for the null pointer detection. It creates a hash of all existing NULL *)
(* pointers in the program. This hash is analyzed by the real null pointer visitor *)
class nullPointerHelperVisitor varmap graph = object(self)
  inherit nopCilVisitor

  val current_fun = ref ""
  val nullpointerHash:(Cil.lval*string,location) Hashtbl.t = Hashtbl.create 5

  method getNullPointerHash = nullpointerHash

  method private addNullPointer vp fn loc =
    Hashtbl.add nullpointerHash (vp,fn) loc

  method vfunc (f:fundec) =
  begin
        current_fun := f.svar.vname;
        DoChildren
  end

  method vinst (i:instr) =
  begin
        match i with
         Set ((hst,off), exp, loc) ->
          (* do the stuff here *)
          begin match exp with
            (* check for NULL pointers only *)
            CastE (t,e) -> if isPointerType t then begin
              match isInteger e with
              (* we found a NULL pointer: *)
              (* (hst,off) points to 0 *)
              Some x -> if Int64.to_int x=0 then begin
                 self#addNullPointer (hst,off)
                 !current_fun loc;
        let rec find_nulls varn funn =
         junkmsg "\n]] entered find_nulls %s\n" funn;
         (* does varn gets modified in 'funn'? *)
         let vm_hash = varmap#getVarMapFormalsHash in
         let _ = 
         try
           let found = Hashtbl.find vm_hash (varn,funn) in
           (* variable modification happens later *)
           (* than the NULL definition *)
           if found.line > loc.line then begin
            (* function was defined NULL and now is set to *)
            (* something else, so remove it from the NULL list *)
            Hashtbl.remove nullpointerHash (varn,funn);
            junkmsg "DEBUG: removed NULL value defined at %d\n" loc.line
           end
         with Not_found -> () in
         (* callee check *)
         let callee = Hashtbl.find graph funn in
         if Hashtbl.length callee.cnCallees <> 0 then begin
           Hashtbl.iter (fun funname (node,argv,floc,fform,retval,loc2) ->
              (* FIXME: big problem here. fform contains somehow only the formals of main *)
              (* and nothing else ..something is broken here. instead of the fform from funname *)

              (* check if one of the argv contains the NULL ptr 'varn' *)
              let arg_cnt = ref 0 in
              let in_argv = List.exists (fun expi ->
                match expi with
                 Lval l -> if l=varn then 
                             true 
                           else begin 
                             arg_cnt:=!arg_cnt+1; false 
                           end
                 |_ -> criticalmsg "ERROR utilvisitor.ml\n"; false) argv in
              (* if one callee has a NULL ptr in its argument list, check if *)
              (* this argument gets modified in the function *)
              if in_argv then begin
                junkmsg "DEBUG: in argv with cnt %d len %d %s\n" !arg_cnt (List.length fform) funname;
                (* arg contains the arg_cnt formal of function funname *)
                let arg = List.nth fform !arg_cnt in
                let v = print_s_lval(getNameOfLval (var(arg))) in
                junkmsg "DEBUG: does it exist checking for %s:%s\n" v funname;
                find_nulls (var(arg)) funname
              end

           ) callee.cnCallees
         end in (* end callee *) 
         
         find_nulls (hst,off) !current_fun
                                end (* if Int64.to_int x=0 then begin' *)
                                
                             |None -> junkmsg "none\n"; ()
                           end; false
                        |_ -> false end; 
                DoChildren

         | _ -> DoChildren
  end
end


(*------------------------------------------------------------------*)
(* keeps track of global variables and their initial values *)
class globalVarInitVisitor = object(self)
  inherit nopCilVisitor
  
  val globalHash:(varinfo, init option) Hashtbl.t = Hashtbl.create 2

  method getInitOfVarinfo v =
        (* might raise Not_found ! *)
        Hashtbl.find globalHash v

  method vglob (g:global) =
  begin
        match g with
        GVar(var,initi,_) -> Hashtbl.add globalHash var initi.init; DoChildren
        | _ -> DoChildren
  end
end



(*------------------------------------------------------------------*)
(* keep track of pointers and null pointers *)
(* TODO: pointer declaration in globals *)
class pointerVisitor = object(self)
  inherit nopCilVisitor

  val current_fun = ref ""
  val pointerHash:(s_lval*string,s_lval) Hashtbl.t = Hashtbl.create 5

  method getPointerHash = pointerHash

  method private addPointer vp fn vn =
        Hashtbl.add pointerHash (vp,fn) vn

  method showPointers =
        Hashtbl.iter (fun (vp,fn) vn ->
                        Printf.printf "Variable %s in %s points to %s\n" (print_s_lval vp) 
                        fn (print_s_lval vn)) pointerHash

  method vfunc (f:fundec) =
  begin
        current_fun := f.svar.vname;
        DoChildren
  end

  method vinst (i:instr) =
  begin
        match i with
         Set ((hst,off), exp, loc) ->
                (* if hst and exp are both lval's then it's a real pointer to a pointer *)
                let lval_is_lval = (isPointerType(typeOfLval (hst,off)) || 
                                        isArrayType(typeOfLval(hst,off)))  in
                let exp_is_lval = begin match exp with
                                (* check for normal pointers *)
                                Lval l -> isPointerType(typeOfLval l)
                                |_ -> false end in
                if lval_is_lval = exp_is_lval then
                begin
                 (* lname points to ename *)
                 let lname = getNameOfLval (hst,off) in
                 let ename = getNameOfExp exp in
                 self#addPointer lname !current_fun ename
                end;
                DoChildren

         | _ -> DoChildren
  end
end


