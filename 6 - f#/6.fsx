
let rec iterateState(fishes : list<uint64>, times:int):uint64=
    if times > 0 then
         let [p8; p7; p6; p5; p4; p3; p2; p1; p0] = fishes
         iterateState([p0; p8; p7 + p0; p6; p5; p4; p3; p2; p1], (times - 1))
    else
        fishes |> Seq.sum

let myAssert input output=
    if input = output then () else printfn "%i != %i" input output  
    input = output

let test =
    printfn "asserting"
    let testIn = List.ofSeq([0; 0; 0; 0; 1; 2; 1; 1; 0] |> Seq.map(fun x -> uint64(x)))
    myAssert (iterateState(testIn, 18)) 26UL &&
    myAssert (iterateState(testIn, 80)) 5934UL


let getInputFishes =
    dict (List.ofSeq(System.IO.File.ReadAllText("6 - f#/input.txt").Split(',')  
    |> Seq.map System.Int32.Parse 
    |> Seq.groupBy (fun x -> x) )
    |> Seq.map (fun (key, values) ->  (key, uint64(values |> Seq.length))))

let getInputFishesArr = 
    [
        (if getInputFishes.ContainsKey(8) then getInputFishes.[8] else 0UL);
        (if getInputFishes.ContainsKey(7) then getInputFishes.[7] else 0UL);
        (if getInputFishes.ContainsKey(6) then getInputFishes.[6] else 0UL);
        (if getInputFishes.ContainsKey(5) then getInputFishes.[5] else 0UL);
        (if getInputFishes.ContainsKey(4) then getInputFishes.[4] else 0UL);
        (if getInputFishes.ContainsKey(3) then getInputFishes.[3] else 0UL);
        (if getInputFishes.ContainsKey(2) then getInputFishes.[2] else 0UL);
        (if getInputFishes.ContainsKey(1) then getInputFishes.[1] else 0UL);
        (if getInputFishes.ContainsKey(0) then getInputFishes.[0] else 0UL)
    ]

iterateState(getInputFishesArr, 80);;
iterateState(getInputFishesArr, 256);;