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
(* detecting NULL pointer dereferences *)
open Cil
open Data
open Utilvisitors

class nullPtrVisitor ptr = object(self)
  inherit nopCilVisitor

  val current_fun = ref ""
  val declared_vars:(string*string,location) Hashtbl.t = Hashtbl.create 15


  method vfunc (f:fundec) =
  begin
        (* save the current function name *)
        current_fun := f.svar.vname;
        DoChildren
  end

  (* invoked on each variable use *)
  method vvrbl (v:varinfo) = 
  begin
        (* only consider referenced variables *)
        if v.vreferenced then begin
          let varname = v.vname in
         (* make sure we are not analyzing the variable declaration! *)	  
         if !currentLoc.line > v.vdecl.line then begin

          (* hash has signature: Cil.lval * string -> location *)
          let h = ptr#getNullPointerHash in
        
          (* make an lval out of the varinfo to simplify the *)
          (* query in the hashtbl *)
          let lval_from_varinfo = var v in
          try
            (* check the NULL-pointer hashtable if this varinfo is existant *)
            let data = Hashtbl.find h (lval_from_varinfo, !current_fun) in

            (* make sure we are not analyzing the NULL declaration either *)
            (* XXX this is a small bug, when the NULL declaration and the dereferencing is *)
            (* located on the same line, then the bug is not reported *)
            if !currentLoc.line > data.line then 
              Printf.printf "line %d: Found NULL pointer dereference of var %s in function %s !\n" (!currentLoc.line) 
		varname !current_fun
          with Not_found -> ()
        end
      end;
        SkipChildren
  end

end
