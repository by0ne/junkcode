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

(* checks all arguments of @dangerousFn for tainted *)
(* variables and issues an error if something was found *)
class bufferOverflowVisitor = object(self)
  inherit nopCilVisitor

  val mutable dangerousFn = ["strcpy";"strncpy";"memcpy";"memccpy";"memmove";"bcopy";
  "sprintf";"sscanf";"strcat";"strncat";"strnset"]

  method addWrappers w =
    dangerousFn <- w @ dangerousFn

  (* TODO: *)
  (*    - add information which argument is tainted to *) 
  (*      the output 
  *)
  method vinst (i:instr) = 
  begin
    match i with
    (* look for dangerousFn calls and see if *)
    (* one of their arguments is tainted *)
    Call(ret,name,args,_) ->
      let n = begin match getNameOfExp name with
        (SVar x,_) -> x
        | _ -> "@@error bufferoverflow@@"
      end in
      (* if the current function call is one of the dangerousFn *)
      if List.mem n dangerousFn then begin
        let found = List.exists (fun x -> 
          (* don't run on constant or void arguments *)
          if isConstant x then false else begin
          let varinfo' = getVarinfoOfLval(getLvalOfExp(x)) in
          (*Printf.printf "varinfo of %s is %d\n" varinfo'.vname 
          varinfo'.vdecl.line;*)
          varinfo'.vtainted end) args in
        if found then
          Printf.printf "line %d: FATAL, found use of tainted variable \
          in dangerous function\n"
          !currentLoc.line
      end; DoChildren
    | _ -> DoChildren
  end

  (* arrays with variable array indices are handled as lvals *)
  (* with Index(Lval(l), NoOffset) *)
  (* if the index @l is tainted, then issue a warning *)
  method vlval (l:lval) =
  begin
    let (lv, off) = l in
    match off with
     NoOffset -> DoChildren
     (* TODO: add multidimensionality here. let rec on @o *)
     |Index(e, o) -> begin match e with
       Lval lindex -> if not (isConstant e) then begin
         let var' = getVarinfoOfLval lindex in
         if var'.vtainted then
           Printf.printf "line %d: use of tainted array index '%s'\n" !currentLoc.line
           var'.vname
       end
       | _ -> ()
       end; DoChildren

     | _ -> DoChildren;
  DoChildren
  end

end
