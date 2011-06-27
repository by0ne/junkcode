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
open Utilvisitors
open Data
open Logger
module P = Printf
module H = Hashtbl

(* TODO: 
        - multidim for var index arrays 
        - fix bug:
                array[0] always notifies OOB
                (constant index) if array was defined with
                type array[];
*)

(* experimental *)
(* returns true if l:Lval is used *)
(* in the matched expression *)
let rec lvalInExp l = function
  Const(_) -> false
  |Lval(x) when x=l -> true
  |SizeOfE(e) -> lvalInExp l e
  |AlignOfE(e) -> lvalInExp l e
  |UnOp(_,e,_) -> lvalInExp l e
  |BinOp(_,e1,e2,_) -> (lvalInExp l e1 || lvalInExp l e2)
  |CastE(_,e) -> lvalInExp l e
  |AddrOf(x) when x=l -> true
  |StartOf(x) when x=l -> true
  |_ -> false

(* simple binop calculator *)
let calcBinOp a b = function
        Lt -> a < b
        |Gt -> a > b
        |Le -> a <= b
        |Ge -> a >= b
        |Eq -> a = b
        |Ne -> a != b
        | _ -> false

exception No_Int_Expr of Cil.exp * bool 

(* analysis of the BinOp expression in the exit condition of a *)
(* loop. Used in the outOfBoundsVarIndexVisitor *)
(* called on expr: if(i < 100) { .. } *)
(* @b: used binop *)
(* @l: index variable, 'i' *)
(* @e1,@e2: left and right expr of @b, one of them is @l *)
(* @len: defined array length *)
let handleBinOp (b:binop) (l:lval) (e1:exp) (e2:exp) (len:int) =
        (*ignore (Errormsg.log "DEBUG: e1 %a\ne2 %a\n" d_exp e1 d_exp e2);*)
        (* on which side is the variable @l? *)
        let is_left = ref true in
        (* check which of the two expressions is NOT the lval l *)
        (* which is our array index. @l contains e.g. "i" *)
        let current_e = ref e2 in
        if lvalInExp l e2 then begin
                current_e := e1;
                is_left := false
        end;
        match isInteger (constFold true !current_e) with
          (* if !current_e is not an integer then it's probably such a construct: *)
          (*    if(i < length) { .. } *)
          None -> criticalmsg "Error: BinOp in contcond is not an \
                  integer, handleBinOp %d\n" !currentLoc.line; raise (No_Int_Expr (!current_e,!is_left))
          (* now both values of the BinOp are known @l and @x *)
          (* apply the BinOp on it to see if the expression is true *)
          (* or false *)
          |Some x -> criticalmsg "DEBUG: integer: %d\n" (Int64.to_int x);
                (* if @offbyN is true then @len is 'smaller' than the used index *)
                let offbyN = ref false in
                if !is_left then 
                 offbyN := (calcBinOp len (Int64.to_int x) b)
                else
                 offbyN := (calcBinOp (Int64.to_int x) len b);

                if !offbyN then 
                  Printf.printf "line %d: exit condition of this loop and \
                  array length do not match\n" !currentLoc.line


(* cares about variable array indices *)
class outOfBoundsVarIndexVisitor contcond breakcond ginit varmap curfun = object(self)
  inherit nopCilVisitor

  val is_endless = ref false 
  val current_block = ref (mkBlock [])

  (* this method is called only once because we use visitCilBlock *)
  (* on it. It only sets the @is_endless reference *)
  method vblock (b:block) =
  begin
        current_block := b;
        (* returns whether this loop contains an break condition *)
        match contcond with
                None -> is_endless := true; DoChildren
                (* the loop with an defined exit condition has 2 successor *)
                (* statements. The one with no exit condition has only 1 successor *)
                | Some x -> if (List.length x.succs)=1 then is_endless:=true else 
                is_endless:=false; DoChildren
  end


  (* arrays with variable array indices are handled as lvals *)
  (* with Index(Lval(l), NoOffset) *)
  (* e.g. a[i] = 'c'; *)
  method vlval (l:lval) =
  begin
        let rec get_indices = function
                    TArray (t,eo,attr) -> let al = try lenOfArray eo with LenOfArray -> -1 in
                                    al :: (get_indices t)
                    | TPtr(t,a) -> junkmsg "pointer typ!\n";  [-3]
                    | _ -> [-3] in

        (* the @e is the array index used *)
        (* e.g. 'i' *)
        let handle_loop (e:Cil.lval) defined_len =
                (*let (lh,offs) = l in*)
                let match_stmt = function 
                  None -> ()
                  (* matching on the exit condition statement *)
                  (* checking if the exit condition contains the current array *)
                  (* index. If not then skip it. *)
                  | Some s -> 
                        let rec doit = function 
                        (* at this point lvalInExp returns the boolean *)
                        (* whether the current array index is part of *)
                        (* the break/continue condition *)
                        If(ifexp,_,_,_) -> if lvalInExp e ifexp then begin
                                (*Printf.printf "DEBUG index is part of ifexp with: ";*)
                
                                (* handle the ifexp, mostly used is BinOp probably *)
                                (* TODO: handle other cases than BinOp *)
                                (match constFold true ifexp with
                                BinOp(b,exp1,exp2,t) -> 
                                        (* if isIntegralType t then .. *)
                                        begin try
                                          handleBinOp b e exp1 exp2 defined_len
                                        with No_Int_Expr(vexpr,is_left) -> begin
                                        (* if this exception is raised then *)
                                        (* we have a variable exit condition in *)
                                        (* the loop. try to evaluate @vexpr *)
                                        let varvar = getVarinfoOfLval(getLvalOfExp vexpr) in 

                                        if varvar.vtainted then 
                                          Printf.printf "line %d: tainted exit condition in this loop\n"
                                          !currentLoc.line;

                                        (* if its a global variable, look it up *)
                                        if varvar.vglob then begin
                                          (* might raise Not_found *)
                                          begin try 
                                          let init = ginit#getInitOfVarinfo varvar in 
                                          match init with
                                          (* uninitialized global var, mostly stored in BSS (0)*)
                                          None -> () 
                                          (* @i is the initial value *)
                                          | Some(SingleInit(rval)) -> 
                                            (* try again handleBinOp with @rval *)
                                            begin try
                                              (* @is_left tells us which expN contains @e *)
                                              if is_left then
                                               handleBinOp b e exp1 (constFold true rval) defined_len
                                              else
                                               handleBinOp b e (constFold true rval) exp2 defined_len
                                            with No_Int_Expr _ -> Printf.printf "Skipping: strange\n"
                                            end

                                          | _ -> criticalmsg "Skipping: CompoundInit line %d\n"
                                                !currentLoc.line

                                          with Not_found -> criticalmsg "giving up line %d var %s\n"
                                          !currentLoc.line varvar.vname
                                          end;
                                        end else begin
                                        (* the variable in the BinOp wasn't a global so look it up *)
                                        (* in the locals and give it up if this wasn't successful *)
                                         begin try
                                         let rval = Hashtbl.find varmap#getVarMapLocalsHash 
                                                                 ((getLvalOfExp vexpr), curfun) in
                                         (* try again with @rval *)
                                         try
                                          if is_left then
                                            handleBinOp b e exp1 rval defined_len
                                          else
                                            handleBinOp b e rval exp2 defined_len
                                         with No_Int_Expr _ -> criticalmsg "Skipping: very strange\n"

                                         with Not_found -> infomsg "giving up search line %d\n"
                                         !currentLoc.line
                                         end

                                        end
                                        end
                                        end

                                | _ -> criticalmsg "Error: not binop in\
                                        contcond:%d\n" !currentLoc.line)
                                end
                        | _ -> () in doit s.skind;
                        List.iter (fun x -> doit x.skind) s.succs
                in match_stmt contcond in

                              
        let (lv,off) = l in
        (*ignore (Errormsg.log "visiting line %d: %a\n" !currentLoc.line d_lval l);*)

        match off with
                NoOffset -> (); DoChildren
                (* IF there is an array access in this loop which has a variable *)
                (* index then we should see it here *)
                | Index(e,o) -> begin match e with
                        (* Lval lindex is the index of the array *)
                        (* TODO: add multidimensionality *)
                        Lval lindex -> if !is_endless then begin
                                (* if there is an endless loop where the *)
                                (* index of an array gets modified, issue *)
                                (* a warning *)
                                let cFM = new checkForModification lindex in
                                (visitCilBlock (cFM:>cilVisitor) !current_block);
                                if cFM#isModified then 
                                  P.printf "line %d: detected endless loop where \
                                  current array index gets modified. Potentially \
                                  dangerous.\n" !currentLoc.line 
                                end else begin
                                  (* XXX: lets hope this works, might raise Lval_not_found *)
                                  (* get the current array indices for the used variable *)
                                  let this_lval = getVarinfoOfLval l in
                                  let defined_indices = get_indices this_lval.vtype in

                                  (* lindex: array index variable *)
                                  (* defined_indices: defined index length *)
                                  handle_loop lindex (List.hd defined_indices)
                                end
                        | _ -> ()
                        end; DoChildren
                | _ -> DoChildren;
        DoChildren
  end
end

(* visitor for analyzing array accesses *)
(* it is split in different parts. This one cares about *)
(* constant indices and for invoking the variable indices analyzer *)
class outOfBoundsVisitor ginit varmap = object(self) 
  inherit nopCilVisitor

  val current_fun = ref ""

  val current_var = ref (makeVarinfo true "@@dummy@@" voidType)
  val scope_var = ref ((makeVarinfo true "@@dummy@@" voidType), [ ])

  (*val arrayHash:(string*varinfo, int list) Hashtbl.t = Hashtbl.create 5*)

  (*method addArray fn vn value =
        H.add arrayHash (fn,vn) value*)

  method vfunc (f:fundec) =
  begin
        current_fun := f.svar.vname;
        prepareCFG f;
        DoChildren
  end

  method vstmt (s:stmt) =
  begin
        match s.skind with
         (* we handle arrays in loops differently *)
         Loop(b,_,stmt1,stmt2) -> 
                (* setup the visitor for variable indices *)
                let oobVIV = new outOfBoundsVarIndexVisitor stmt1 stmt2 ginit 
                                                            varmap !current_fun in
                (visitCilBlock oobVIV b); 
                (*ignore(Errormsg.log "-> %a\n" d_stmt s);*)
                DoChildren
         | _ -> DoChildren
  end


  (* invoked on each variable use *)
  (* e.g. p[3] = 'c'; *)
  method vvrbl (v:varinfo) =
  begin
    if isArrayType v.vtype then begin
        current_var := v;
        (*Printf.printf "visiting array type %d\n" !currentLoc.line;*)
        (* trying to get all indices of a multidimensional array *)
        let rec get_indices = function
                    TArray (t,eo,attr) -> let al = try lenOfArray eo with LenOfArray -> -1 in
		                    al :: (get_indices t)
                    | _ -> [-3] in 

        let defined_len = get_indices v.vtype in
        (*P.printf "DBG: defined len is %d\n" (List.hd defined_len);*)
        (*self#addArray !current_fun !current_var defined_len;*)
        scope_var := (!current_var, defined_len)
    end;
    (*DoChildren*)
    SkipChildren
  end


  (* checking current array index offsets *)
  (* this current index can be compared with the declared index in method vvdec  *)
  method voffs (o:offset) = 
  begin
    try 
      (* first try to get all used offsets from this array (might be multidimensional) *)
      let rec get_indices = function
                   Index (e,off) -> let al = try lenOfArray (Some e) with LenOfArray -> -1 in
		             al :: (get_indices off)
                   | _ -> [-2] in

      let current_len = get_indices o in
 
      (* get the current array with its list of indices *)
      let (v,defined_len) = !scope_var in 
      (* compare all defined with all used indices *)
      let cnt = ref 0 in
      let unsafe_index = List.exists2 (fun a b ->
        (*P.printf "DBG: defined %d current %d\n" a b;*)
        if (a = -3 || b = -2) then false
        else
        if b >= a then true else begin cnt:=!cnt+1; false end) defined_len current_len in

      if unsafe_index then begin
        Printf.printf "line %d: array out of bound access found on variable %s, \
  	at least index %d is too big.\n" !currentLoc.line v.vname !cnt
      end; SkipChildren
    with Invalid_argument _ -> ((*Printf.printf "DBG: exception\n"*));

    (* skip the children since we got all the offsets in this offset with get_indices *)
    SkipChildren
  end
end

