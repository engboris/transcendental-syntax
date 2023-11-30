open Base

(* ---------------------------------------
   Few useful functions
   --------------------------------------- *)
   
let lift_pairl f (x, y) = (f x, y)
let lift_pairr f (x, y) = (x, f y)
let lift_pair f p = lift_pairr f (lift_pairl f p)

let without i l = List.foldi l ~init:[] ~f:(fun j acc x -> if i=j then acc else acc@[x])
let replace x y l = List.map ~f:(fun e -> if x=e then y else e) l
let extract i l = (List.nth l i, without i l)