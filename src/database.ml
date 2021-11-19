open Core

let db_schema_file = "./data/schema.sql"


    
let create_schema (_: Sqlite3.db) = 
    db_schema_file
    |> In_channel.read_all
    |> String.split_on_chars ~on:[';']
    |> fun l -> print_string @@ "Loaded schema file with " ^ (Int.to_string @@ List.length l) ^ " commands.\n"

