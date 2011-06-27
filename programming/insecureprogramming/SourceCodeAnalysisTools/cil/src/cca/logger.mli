(*val critical : int option
val warn : int option
val info : int option
val junk : int option
val no_debug : 'a option*)
val debuglevel : int option
(*val logit : ?ll:int option -> ('a, unit, string, unit) format4 -> 'a*)
val junkmsg : ('a, unit, string, unit) format4 -> 'a
val criticalmsg : ('a, unit, string, unit) format4 -> 'a
val warnmsg : ('a, unit, string, unit) format4 -> 'a
val infomsg : ('a, unit, string, unit) format4 -> 'a
