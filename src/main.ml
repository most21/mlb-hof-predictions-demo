(* open Core *)

(* 
    The Hof library contains all the modules defined in src: cli, TODO
    Note that this project is not affiliated with David "The Hoff" Hasselhoff in any way)
*)
open Hof
open Sqlite3

let db_file = "mlb-hof.db"

let () = 
    let& _ = Sqlite3.db_open db_file in
    Cli.run_main_menu_loop ()