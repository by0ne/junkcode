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
open Data
open Callgraph
open Utilvisitors
open Logger

(* runs on all functions which introduce user input into a program *)
(* marks the variables where this user input is stored as tainted  *)
class userInputTraceVisitor = object(self)
  inherit nopCilVisitor

  (* (name, argument) *)
  (* '-1' as argument means return value of the function is tainted *)
  val mutable inputFns = [("read", 1); ("recv", 1); ("recvfrom", 1); ("fread", 0) ]

  (* this fun may extend the @inputFns list *)
  method addWrappers w =
    inputFns <- w @ inputFns 

  (* TODO: if f = @inputFns then set @argument tainted! *)
  (*method vfunc (f:fundec) =
  begin
  end*)
  
  method vinst (i:instr) =
  begin
    match i with
    Call(ret,name,argv,_) ->
      (* @n contains the function name as string *)
      let n = begin match getNameOfExp name with
        (SVar x, _) -> x
        | _ -> "@@error input@@"
      end in

      begin try
        (* @i_nbr: argument nbr containing user input *)
        let i_nbr = List.assoc n inputFns in
        (*Printf.printf "userinput: considering fn %s\n" n;*)
        
        (* get @i_nbr'th argument of argv *)
        let i_exp = 
          if i_nbr >= 0 then List.nth argv i_nbr 
          else
          (* the argument was -1, so get the ret expr *)
          begin match ret with
            Some x -> Lval(x)
            (* if it's a constant then it'll be skipped below *)
            | None -> Const(CStr("nothing")) 
          end in
          
        (* don't run getLvalOfExp on constant values *)
        (* this would raise an exception *)
        if not (isConstant i_exp) then begin
          let i_var = getVarinfoOfLval(getLvalOfExp(i_exp)) in
          (*Printf.printf "userinput: marking var %s as tainted\n" i_var.vname;*)
          i_var.vtainted <- true
        end; DoChildren
      with Not_found -> (); DoChildren
      end
    | _ -> DoChildren

  end
end

(* must be run after userInputTraceVisitor *)
(* spreads the information of tainted variable through the program *)
(* TODO:
        - implement copy functions which are alternatives to Set instr 
*)
class spreadTaintedInputHelper graph retobj = object(self)
  inherit nopCilVisitor

  (* if a function is called then set its formals tainted *)
  (* according to the calling args. *)
  method vfunc (f:fundec) =
  begin
    let oldname = ref "" in
    junkmsg "entered %s\n" f.svar.vname;

    let rec find_fun fname =
    (* get the callers *)
    let callers = Hashtbl.find graph fname in
    if Hashtbl.length callers.cnCallers <> 0 then begin

      try
      Hashtbl.iter (fun funname (node,argv,_,forms) ->
        (* if one argv of a caller is tainted then set the current formals *)
        (* to tainted aswell! the return value @found is not really needed *)

        (*Printf.printf "DBG: '%s' argv %d <-> this formals %d @%d\n" funname 
        (List.length argv) (List.length f.sformals) !currentLoc.line;*)

        (* avoid endless loops *)
        if funname <> !oldname then
          find_fun funname
        else
          (* if the old and the new name are the same *)
          (* then it's better to break out of the Htbl.iter *)
          (* to prevent endless loops *)
          raise Not_found;

        oldname := funname;
        (* compare calling argv with current formals for taintedness *)
        (* XXX: if @funname is a varargs function then this will probably fail *)
        (*      because the calling arg and defined are not equal *)
        try 
        let found = List.exists2 (fun x y ->
          (* be sure not to run getLvalOfExp on constants *)
          if isConstant x then false 
          else begin
            let var' = getVarinfoOfLval(getLvalOfExp(x)) in
            (*if var'.vtainted then *)
              (* this makes untainting possible *)
              y.vtainted <- var'.vtainted;

            if fst var'.vmalloced then begin
              infomsg "tainted: marking %s as malloced\n" y.vname;
              y.vmalloced <- var'.vmalloced
            end;
            var'.vtainted 
          end) argv f.sformals in ()
        with Invalid_argument _ -> 
          criticalmsg "tainted: giving up. probably varargs@%d\n"
          !currentLoc.line
          (*Printf.printf "functions %s has tainted arg: %b\n" funname found*))
        callers.cnCallers 
        with Not_found -> junkmsg "breaking endless loop!\n"
    end in

    find_fun f.svar.vname;
    DoChildren
  end

  method vinst (i:instr) =
  begin
    match i with
    (* if @e is tainted => mark @l as tainted *)
    Set(l,e,_) -> 
      (* only act on non-constant exprs *)
      if not (isConstant e) then begin
        let i_var = getVarinfoOfLval(getLvalOfExp(e)) in
        (*if i_var.vtainted then begin*)
          let i_lv = getVarinfoOfLval(l) in
          infomsg "spreadTaintedInput: marking var %s as tainted:%b\n" i_lv.vname i_var.vtainted;
          i_lv.vtainted <- i_var.vtainted;
        (*end;*)
        if fst i_var.vmalloced then begin
          let i_lv = getVarinfoOfLval(l) in
          (*Printf.printf "spreadTaintedInput: marking var %s as malloced\n" i_lv.vname;*)
          infomsg  "spreadTaintedInput: marking var %s as malloced\n" i_lv.vname;
          i_lv.vmalloced <- i_var.vmalloced
        end
      end; DoChildren

    (* returned values of function can be tainted too *)
    |Call(ret,name,argv,_) -> 
      (* only process calls with return value *)
      begin match ret with
      (* get the function name in @funname *)
      Some r -> let funname = getVarinfoOfLval(getLvalOfExp name) in
        let hh = retobj#getRetHash in
        begin try
          (* lookup the function name's return expression *)
          let rval = Hashtbl.find hh (funname.vname) in
          match rval with
           Some rr -> 
               if not (isConstant rr) then begin
               (* check if the return expression is based on a tainted var *)
               let rvarinfo = getVarinfoOfLval(getLvalOfExp rr) in
               (*if rvarinfo.vtainted then begin*)
                let r' = getVarinfoOfLval(r) in
                r'.vtainted <- rvarinfo.vtainted;
               (*end;*)

               if fst rvarinfo.vmalloced then begin
                let r' = getVarinfoOfLval(r) in
                r'.vmalloced <- rvarinfo.vmalloced
               end
             end
           |None -> ()

        with Not_found -> ()
        end; DoChildren

      | _ -> DoChildren
      end
    | _ -> DoChildren
  end
end

