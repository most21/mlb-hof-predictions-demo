(* open Core *)

(* 
    The Hof library contains all the modules defined in src: Cli, Database
    Note that this project is not affiliated with David "The Hoff" Hasselhoff in any way)
*)
open Hof
(* open Sqlite3 *)

let db_file = "mlb-hof.db"

let () = 
    Cli.run_main_menu_loop ()