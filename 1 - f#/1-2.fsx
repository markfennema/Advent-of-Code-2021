let getLines () =
    List.ofSeq(System.IO.File.ReadLines("1/input.txt")  |> Seq.map System.Int32.Parse)

let rec countAscents2 l acc=
    match l with
        | a :: b :: c :: d :: tail -> countAscents2 (b :: c :: d :: tail)  acc + (if a < d then 1 else 0)
        | _ -> 0

let runCode2 =
    countAscents2(getLines()) 0

let myAssert input output=
    if input = output then () else printfn "%i != %i" input output  
    input = output

let test2 =
    myAssert (countAscents2 [199; 200; 208; 210; 200; 207; 240; 269; 260; 263] 0) 5;;