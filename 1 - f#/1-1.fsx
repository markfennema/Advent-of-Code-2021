let getLines () =
    List.ofSeq(System.IO.File.ReadLines("1/input.txt")  |> Seq.map System.Int32.Parse)

let rec countAscents l acc=
    match l with
        | a :: b :: tail -> countAscents (b :: tail) acc + (if b > a then 1 else 0)
        | _ -> 0

let runCode =
    countAscents(getLines()) 0

let myAssert input output=
    if input = output then () else printfn "%i != %i" input output  
    input = output

let test =
    myAssert (countAscents [2; 3; 2] 0) 1 &&
    myAssert (countAscents [2; 3] 0) 1 &&
    myAssert (countAscents [] 0) 0 && 
    myAssert (countAscents [2; 3; 4] 0) 2 &&
    myAssert (countAscents [2; 3; 2; 4] 0) 2;;