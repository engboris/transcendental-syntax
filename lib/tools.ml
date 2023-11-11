(* ---------------------------------------
   Few useful functions
   --------------------------------------- *)
   
let lift_pairl f (x, y) = (f x, y)
let lift_pairr f (x, y) = (x, f y)
let lift_pair f p = lift_pairr f (lift_pairl f p)

let foldi_left f acc l =
	snd (List.fold_left (fun (i, acc') x -> (i+1, f i acc' x)) (0, acc) l)

let without i l = foldi_left (fun j acc x -> if i=j then acc else acc@[x]) [] l
let replace x y l = List.map (fun e -> if x=e then y else e) l
let extract i l = (List.nth l i, without i l)

(* ---------------------------------------
   List monad (with index)
   --------------------------------------- *)
   
let return x = [x]
let (>>=) l f = List.flatten (List.mapi f l)
