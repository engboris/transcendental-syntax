(* ---------------------------------------
   Few useful functions
   --------------------------------------- *)
   
let lift_pairl f (x, y) = (f x, y)
let lift_pairr f (x, y) = (x, f y)
let lift_pair f p = lift_pairr f (lift_pairl f p)

let rec repeat_string s n = if n=0 then "" else s ^ repeat_string s (n-1)

let foldi_left f acc l =
	snd (List.fold_left (fun (i, acc') x -> (i+1, f i acc' x)) (0, acc) l)

let without i l = foldi_left (fun j acc x -> if i=j then acc else acc@[x]) [] l

(* ---------------------------------------
   List monad (with index)
   --------------------------------------- *)
   
let return x = [x]
let (>>=) l f = List.flatten (List.mapi f l)