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
open Cil
open Trace
open Printf
open Callgraph
open Data
open Utilvisitors
open Nullptr
open Outofbounds
open Userinput
open Bufferoverflow
open Mallocfree
open Dumper
module P = Pretty
module H = Hashtbl

let version = "CCA 0.8, 30.04.05\n"

(* TODO:
        - (malloc): handle free on global variables !!!
          This causes a List.nth currently
*)

type malloc_status = {
        var_status: int;
        var_loc: location;
        var_name: s_lval;
}

let input_wrapper_list = ref []
let malloc_wrapper_list = ref []
let dangerous_wrapper_list = ref []

(* ---------------------------------------------------------- *)

(* this visitor simply keeps track of all malloc() calls. *)
(* It saves all lval's of the malloc() calls in the mallocHash, accessible *)
(* via getMallocHash method. The hash has (varname, funname) as key and type *)
(* malloc_status as data. *)
class mallocVisitor = object(self) 
  inherit nopCilVisitor

  val current_fun = ref ""

  val mallocHash = Hashtbl.create 5
  val mallocFnHash = Hashtbl.create 5

  val mutable mallocLval = ["malloc"]

  method addWrappers w = 
    mallocLval <- w @ mallocLval
    
  method getMallocHash = mallocHash
  method getMallocFnHash = mallocFnHash

  method private addMalloc vn fn vs l =
        Hashtbl.add mallocHash (vn,fn) {var_status = vs; var_loc = l; var_name = vn};
        Hashtbl.add mallocFnHash fn {var_status = vs; var_loc = l; var_name = vn}

  method summarizeMallocList (a,(b:string)) ms  =
        Printf.printf "line %d: Memory leak, variable %s never freed\n" ms.var_loc.line (print_s_lval a) 

  method removeMalloc vn fn =
  begin
        (*Printf.printf "DEBUG: removing %s in %s\n" vn fn;*)
        (* check if variable exists in the malloc hashtbl *)
        let c = Hashtbl.mem mallocHash (vn,fn) in
        if c = true then begin
                (* variable exists and is malloced, just remove it *)
                Hashtbl.remove mallocHash (vn,fn); true
        end
        (* variable does not exist in the hashtbl, maybe already removed? *)
        else false
  end

  method vfunc (f:fundec) =
  begin
        (* save the current function name *)
        current_fun := f.svar.vname;
        DoChildren
  end

  method vinst (i:instr) =
  begin
        match i with
         (* only interested in function calls *)
         Call(ret,name,argv,loc) -> 
                    let n = begin match getNameOfExp name with
                      (SVar x, _) -> x
                      | _ -> "@@error malloc@@"
                    end in
                    (*if n=mallocLval then begin*)
                    if List.mem n mallocLval then begin
                        (* get the optional return value, maybe  *)
                        (* report an error if malloc does not have a retval? *)
                        let r = (match ret with
                                Some (lh,off) -> (lh,off)
                                |None -> Mem(Const(CStr("dummy"))), NoOffset) in
                        let retval = getNameOfLval r in
                        if (getVarinfoOfLval(r)).vglob then
                          self#addMalloc retval "@@global@@" 1 loc 
                        else
                         self#addMalloc retval !current_fun 1 loc
                    end; DoChildren
        | _ -> DoChildren
  end
end


(* counterpart to the mallocVisitor. It runs on the hashtable created *)
(* from mallocVisitor. *)
(* TODO: *)
(*      - implement pointer-following                          *)
(*      - change to handling real CIL lval                     *)
(*      - solve conditional free problem!                      *)
(*        e.g. free in block with return statement is ignored: *)
(*              free(x)                                        *)
(*              return 0;                                      *)
(*      + implement user defined malloc function wrappers      *)
(*      - catching globally defined variables                  *)
(*      - solve problem with freeing struct fields:            *)
(*              free(p->value);                                *)
class freeVisitor graph mobject robject = object(self)
  inherit nopCilVisitor

  val current_fun = ref ""    (* stores the current function for context *)
  val current_formals = ref [] (* stores the current function arguments *)
  val current_locals = ref []
  val current_svar = ref (makeVarinfo true "empty" voidType)

  val freeLval = (SVar("free"), SNoOffset)

  method vfunc (f:fundec) =
  begin
        (* save the current function name *)
        current_fun := f.svar.vname;
        current_formals := f.sformals;
        current_locals := f.slocals;
        current_svar := f.svar;
        DoChildren
  end

  method vinst (i:instr) =
  begin
        match i with
         (* only interested in function calls *)
         Call(ret,name,argv,loc) -> let n = getNameOfExp name in 
                        (*if n="free" then begin*)
                        if n=freeLval then begin
                          Printf.printf "\nDEBUG entered %s\n" !current_fun;
                          (* get the only argument of free, shouldn't fail *)
                          let a1 = List.hd argv in
                          let arg1 = getNameOfExp a1 in

                          let rec find_free varn funn funlocal funformal =
                            (*Printf.printf "DEBUG examining %s and %s\n" funn varn;*)
                            let continue = ref true in
                            (* check for callees *)
                            let callee = Hashtbl.find graph funn in
                            if Hashtbl.length callee.cnCallees <> 0 then begin
                              Hashtbl.iter (fun funname (node,argv,floc,fform,retval,loc2) ->
                                (* if the function is called before the free() happens *)
                                if loc2.line <= loc.line then begin 
                                  (* check if the retval of the call is our variable *)
                                  (* and if so, then trace the callee *)
                                  (match retval with
                                  Some (l,h) -> let retn = (getNameOfLval (l,h)) in
                                    (* variable used in free and used as return type of a call *)
                                    (* are the same .. *)
                                    if retn=arg1 then begin
                                        (* get the return type of function 'funname' *)
                                        let hh = robject#getRetHash in
                                        (* 'funname' could also be a library call, so the *)
                                        (* Hashtbl searches will fail with Not_found *)
                                        try 
                                          let x = Hashtbl.find hh funname in
                                          (* locals and formals for function funname *)
                                          let fnode = Hashtbl.find graph funname in
                                          (match x with
                                            Some a -> (*Printf.printf "has return var \n";*)
                                              find_free (getNameOfExp a) funname fnode.cnLocals fnode.cnFormals;
                                              continue := false;
                                            |None -> (*Printf.printf "has no return var\n"*) ()
                                          )
                                        with Not_found -> ()
                                    end
                                  | None -> ()) 
                                
                                end
                                
                                ) callee.cnCallees
                             end; 

                            (* if find_free didn't already examine this function, continue *)
                            if !continue then begin

                            (* var in locals? *)
                            let arg_cnt = ref 0 in
                            let in_locals = List.exists (fun x ->
                              (*Printf.printf "---> in local loop %s <-> %s\n" x.vname varn;*)
                              (*if x.vname=varn then *)
                              if x.vname=(print_s_lval_struct varn) then 
                                true 
                              else begin
                                arg_cnt := !arg_cnt+1; false 
                            end) funlocal in

                            (* TODO: if its not in the locals and not in the formals then *)
                            (* check the globals!! *)
                            if in_locals then begin
                                Printf.printf "DEBUG free argument in locals\n";
                                let found = mobject#removeMalloc varn funn in
                                if not found then
                                  (* we have found a problem here: double/dangling free *)
                                  (*    There is a free() of a local variable with no malloc *)
                                  (* only a problem when the traced function has callers *)
                                  Printf.printf "line %d: free of %s, but this variable is not allocated. \
                                  Use of variable traced back to function %s \n"
                                  loc.line (print_s_lval varn) funn
                            end

                            (* the variable where free() is called upon is in the formals *)
                            else begin
                                (* we need this to count which argument in the formal is our var *)
                                (* XXX: if things go wrong and you can't explain why, remove arg_cnt here *)
                                let arg_cnt = ref 0 in
                                let in_formals = List.exists (fun x ->
                                  (*if x.vname=varn then*)
                                  if x.vname=(print_s_lval_struct varn) then
                                    true
                                  else begin
                                    arg_cnt := !arg_cnt+1; false
                                end) funformal in

                                (* foreach caller of function 'funn' recursively call find_free *)
                                let mygraph = Hashtbl.find graph funn in
                                if Hashtbl.length mygraph.cnCallers <> 0 then begin
                                 (* iterate over the callgraph hashtable and examine every *)
                                 (* caller of current function 'funn' *)
                                 Hashtbl.iter (fun funname (node, argv, floc, fform) ->
                                   (* XXX: might raise Not_found *)
                                   begin try 
                                   let varname = (getNameOfExp(List.nth argv !arg_cnt)) in
                                   find_free varname funname floc fform
                                   with Failure "nth" -> 
                                      Printf.printf "Error line %d with List.nth exception arg %d\n"
                                      !currentLoc.line !arg_cnt
                                   end
                                 ) mygraph.cnCallers
                                end 

                                end (* end of 'if !continue then begin' *)
                            end in


                           find_free arg1 !current_fun !current_locals !current_formals
                    end 
                    else begin
                        (* Printf.printf "other call\n";*)
                    end; DoChildren
        | _ -> DoChildren
  end
end


let staticAnalyzer (f:file) =
  let graph = computeGraph f in
  let ro = new returnVarVisitor in

  (*let mo = new mallocVisitor in*)
  let moNEW = new newmallocVisitor in

  moNEW#addWrappers !malloc_wrapper_list;

  (*let fo = new freeVisitor graph mo ro in*)
  let foNEW = new newfreeVisitor moNEW in
  
  let po = new pointerVisitor in
  let go = new globalVarInitVisitor in
  let varmap = new varMapVisitor in

  let uo = new userInputTraceVisitor in
  uo#addWrappers !input_wrapper_list;
  let spo = new spreadTaintedInputHelper graph ro in
  let bufo = new bufferOverflowVisitor in
  bufo#addWrappers !dangerous_wrapper_list;

  (*let nullptrhelper = new nullPointerHelperVisitor varmap graph in
  let ptro = new nullPtrVisitor nullptrhelper in*)

  let oob = new outOfBoundsVisitor go varmap in


  Printf.printf "%s" version;
  (* ------------------------------------*)
  (* Creates a list of all pointers      *)
  (* ------------------------------------*)
  (* running the pointer visitor *)
  (visitCilFileSameGlobals (po :> cilVisitor) f); 

  (* ------------------------------------*)
  (* Creates a list of all return vals   *)
  (* ------------------------------------*)
  (visitCilFileSameGlobals (ro :> cilVisitor) f);

  (* ------------------------------------*)
  (* malloc error detection         *)
  (* ------------------------------------*)
  (*(visitCilFileSameGlobals (mo :> cilVisitor) f);
  (visitCilFileSameGlobals (fo :> cilVisitor) f);*)
  (visitCilFileSameGlobals (moNEW :> cilVisitor) f);

  (* ------------------------------------*)
  (* Mark user input tainted             *)
  (* ------------------------------------*)
  (* declares initial variables tainted  *)
  (visitCilFileSameGlobals (uo :> cilVisitor) f); 
  (* sets all followup vars tainted      *)
  (visitCilFileSameGlobals (spo :> cilVisitor) f); 

  (* ------------------------------------*)
  (* free error detection                *)
  (* ------------------------------------*)
  (visitCilFileSameGlobals (foNEW :> cilVisitor) f);
  (*Hashtbl.iter mo#summarizeMallocList mo#getMallocHash;*)
  Hashtbl.iter moNEW#summarizeMallocList moNEW#getMallocHash;

  (* ------------------------------------*)
  (* Check for possible BO's             *)
  (* ------------------------------------*)
  (visitCilFileSameGlobals (bufo :> cilVisitor) f);

  (* ------------------------------------*)
  (* Out of bound access detection       *)
  (* ------------------------------------*)
  (visitCilFileSameGlobals (go :> cilVisitor) f);
  (Gc.major ());
  (visitCilFileSameGlobals (varmap :> cilVisitor) f);
  (visitCilFileSameGlobals (oob :> cilVisitor) f); 

  (* ------------------------------------*)
  (* NULL pointer detection              *)
  (* ------------------------------------*)
  (*(visitCilFileSameGlobals (nullptrhelper :> cilVisitor) f);
  (* running the null pointer visitor *)
  (visitCilFileSameGlobals (ptro :> cilVisitor) f); *)
  (* ------------------------------------*)

  (* might help prevent exhaustive memory *)

  (* ------------------------------------*)
  
  Printf.printf "done.\n"

let doCallGraph = ref false

(* string list -> (string * int) list *)
let parselist s =
  let ret = ref [] in
  List.iter (fun x -> 
    let l = Str.split (Str.regexp "[, \t]+") x in
    ret := (List.hd l, int_of_string(List.nth l 1)) :: !ret) s; 
    !ret

let feature : featureDescr = 
  { fd_name = "codechecker";
    fd_enabled = doCallGraph;
    fd_description = "C Code Analyzer";
    fd_extraopt = 
    [("--myinput", Arg.String (fun s -> 
      let l = readfile s in
      input_wrapper_list := parselist l), 
    "file containing input wrapper functions");

     ("--mymalloc", Arg.String (fun s ->
      malloc_wrapper_list := readfile s),
    "file containing malloc wrapper functions");

    ("--mydangerous", Arg.String (fun s ->
      dangerous_wrapper_list := readfile s),
    "file containing dangerous wrapper functions");
      
    ];
    fd_doit = 
    (function (f: file) -> 
      let _ = staticAnalyzer f in ());
    fd_post_check = false;
  } 

