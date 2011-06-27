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
(* contains simplified data structures and functions to access/read/print them *)
open Cil
open Data

(* simple representation of an lval *)
type s_lhost = SVar of string | SMem of s_lval
and s_offset = SError | SNoOffset | SField of string
and s_lval = s_lhost * s_offset

let print_s_lval = function
        (SVar x, SNoOffset) -> x
        |(SVar x, SError)  -> "@@error print"
        |(SMem(SVar(x), SNoOffset), SField(y)) -> x ^ "->" ^ y
        |(SMem(SVar(x), SField(y)), SNoOffset) -> x ^ "->" ^ y
        | _ -> "@@error print lval"

let print_s_lval_struct = function
        (SVar x, SNoOffset) -> x
        |(SVar x, SError)  -> "@@error print_"
        |(SMem(SVar(x), SNoOffset), SField(y)) -> x
        | _ -> "@@error print struct"

(* ----------------------------------------------------- *)

let getNameOfOffset = function
        NoOffset -> SNoOffset
        | Field(fi, o) -> SField(fi.fname)
        | _ -> SError


let rec getNameOfLval = function
        Var(v),o -> (SVar(v.vname), getNameOfOffset(o))
        |Mem(m),o -> (match m with
                 Lval (ll,hh) -> (SMem(getNameOfLval(ll,hh)), getNameOfOffset(o))
                 |_ -> (SVar("@@errorXX"), SNoOffset))

let rec getNameOfExp = function
        Lval (l,h) -> getNameOfLval (l,h)
        |Const(c) -> (SVar "@@error1", SNoOffset)
        |AddrOf(lval) -> (SVar "@@error2", SNoOffset)
        |StartOf(lval) -> (SVar "@@error3", SNoOffset)
        |SizeOf(typ) -> (SVar "@@error4", SNoOffset)
        |SizeOfE(exp) -> (SVar "@@error5", SNoOffset)
        |CastE(t,e) -> getNameOfExp e
        |_ -> (SVar "@@error6", SNoOffset)


exception Lval_not_found
let rec getLvalOfExp = function
        Lval(l) -> l
        | SizeOfE e -> getLvalOfExp e
        | AlignOfE e -> getLvalOfExp e
        | CastE(t,e) -> getLvalOfExp e
        | UnOp(_,e,_) -> getLvalOfExp e
        (* consider constant folding on e1/e2.. *)
        (* FIXME: (\*var + len) where len != const *)
        (* raises Lval_not_found, try to handle this *)
        | BinOp(_,e1,e2,_) -> if isConstant e2 then
                                getLvalOfExp e1
                              else if isConstant e1 then
                                getLvalOfExp e2
                              else
				getLvalOfExp e1
                                (*raise Lval_not_found*)
        | AddrOf l -> l
        | StartOf l -> l
        | _ -> raise Lval_not_found

let rec getVarinfoOfLval = function
        (Var v,_) -> v
        |(Mem e,_) -> getVarinfoOfLval(getLvalOfExp e)

let inc x = x:=!x+1

let readfile file =
        let channel = open_in file in
        let rdata = ref [] in

        let rec read_file () =
        try
                        let data = input_line channel in
                                List.filter (fun x ->
                                  if x="" then false else true)
                                (data:: (read_file()));
        with End_of_file -> close_in channel; [] in read_file ()


