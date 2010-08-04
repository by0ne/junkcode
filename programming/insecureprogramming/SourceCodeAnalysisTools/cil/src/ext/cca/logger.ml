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

let critical = Some 1
let warn = Some 2
let info = Some 3
let junk = Some 4
let no_debug = None

(* current debug level, set this to critical
 * in case you are reporting a bug *)
let debuglevel = no_debug

let logit :  ?ll:int option -> ('a, unit, string, unit) format4 -> 'a =
  fun ?(ll=Some 1) fmt ->
    let logic s = 
      begin
      if (match debuglevel, ll with
        Some x, Some y -> if x >= y then true else false
        | _ -> false) then
          begin 
           output_string stdout s
          end;
      end in
   Printf.kprintf logic fmt

let junkmsg (msg: ('a, unit, string, unit) format4) =
  logit ~ll:junk msg
  
let criticalmsg (msg: ('a, unit, string, unit) format4) =
  logit ~ll:critical msg

let warnmsg (msg: ('a, unit, string, unit) format4) =
  logit ~ll:warn msg

let infomsg (msg: ('a, unit, string, unit) format4) =
  logit ~ll:info msg

