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
open Logger

type malloc_status = {
        var_status: int;
        var_loc: location;
        var_name: varinfo;
}

(* keeping track of all malloc calls *)
class newmallocVisitor = object(self)
  inherit nopCilVisitor
 
  val current_fun = ref ""
  val mutable mallocFns = ["malloc"; "strdup"]
  val mallocHash = Hashtbl.create 5
  (* unique malloc id *)
  val mid = ref 0

  method getMallocHash =
    mallocHash

  (* expand the malloc function list with user defined fns *)
  method addWrappers w = 
    mallocFns <- w @ mallocFns

  method private addMalloc vn fn vs l =
    Hashtbl.add mallocHash !mid {var_status = vs; var_loc = l; var_name = vn}

  method summarizeMallocList (id:int) ms  =
    Printf.printf "line %d: Memory leak, variable '%s' never freed\n" 
    ms.var_loc.line ms.var_name.vname

  method removeMalloc id  =
  begin
        (*Printf.printf "DEBUG: removing %s in %s\n" vn fn;*)
        (* check if variable exists in the malloc hashtbl *)
        let c = Hashtbl.mem mallocHash id in
        if c = true then begin
                (* variable exists and is malloced, just remove it *)
                Hashtbl.remove mallocHash id; true
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
    Call(ret, name, argv, loc) ->
      (* only check calls to malloc *)
      let n = begin match getNameOfExp name with
        (SVar x, _) -> x
        | _ -> "@@error malloc2@@"
      end in
      if List.mem n mallocFns then begin
        match ret with
        (* if malloc has a return value then set vmalloced on it *)
        Some r -> let r' = getVarinfoOfLval(r) in
                  (* XXX: maybe check shadowing too *)
                  (* increase the malloc identification number *)
                  inc mid;
                  infomsg "newmalloc: adding var %s with %d\n" r'.vname !mid;
                  r'.vmalloced <- (true, !mid ); 
                  self#addMalloc r' !current_fun 1 loc
        | None -> ()
      end; DoChildren

    |_ -> DoChildren
  end
end

(* TODO: - handle structs *)
(*       - functions which are not called at all but have a free() *)
(*         issue a warning..that's bad! *)
class newfreeVisitor mobject = object(self)
  inherit nopCilVisitor

  val freeFn = "free"
  val current_fun = ref ""

  method vfunc (f:fundec) =
  begin
    current_fun := f.svar.vname;
    DoChildren
  end

  method vinst (i:instr) =
  begin
    match i with
    Call(ret,name,argv,loc) ->
      let n =  begin match getNameOfExp name with
        (SVar x,_) -> x
        | _ -> "@@error free2@@"
      end in
      (* only check free calls *)
      if n = freeFn then begin
        (* free has only one argument (hopefully) *)
        let arg0 = List.hd argv in
        let argvarinfo = getVarinfoOfLval(getLvalOfExp arg0) in

        junkmsg "free call on %s vmalloced: %b * %d @%d\n" argvarinfo.vname
        (fst argvarinfo.vmalloced) (snd argvarinfo.vmalloced) !currentLoc.line;

        (* if it's malloced check the id of it *)
        if not (fst argvarinfo.vmalloced) then 
          Printf.printf "line %d: free of '%s', but this variable is not allocated.\n"
          loc.line argvarinfo.vname 
        else begin
          (* this variable is probably malloced *)
          (* second value of vmalloced contains the id *)
          (* see if this id is in the malloc hash, if not then we have a double *)
          (* free or dangling free *)
          let found = mobject#removeMalloc (snd argvarinfo.vmalloced) in
          if not found then 
            Printf.printf "line %d: free of '%s', but this variable is not \
            allocated.\n" loc.line argvarinfo.vname;

          argvarinfo.vmalloced <- (false, -1)
        end
      end; DoChildren

    |_ -> DoChildren
  end
end
