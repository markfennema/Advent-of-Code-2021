ExUnit.start() # This seems like it'd normally be in a different file, but for AOC this is convenient

# So, again, this is probably the wrong. The right solution would be to fill out a grid data structure with each item which
# would be O(NM + M^2) Where M is the length of the grid and N is the number of lines
# That solution would also be way easier to write and would have cleaner code.
#
# My solution is O(MN^2) and this is almost definitely worse unless the grid is massive
# At the same time: Mine is way more fun, because I had to write up some basic calculus mixed with some odd rules (since
# the vertical lines are not proper functions, and calculus isn't usually just over the integers)
# I can pretend the weird algorithm choice is to save memory if I want to feel better about the performance.

# I should really just have just found a calculus library but that wouldn't be any fun

defmodule Point do
   defstruct [:x, :y]

    def parse_point(str) do
        [str_x, str_y] = String.split(str, ",")
        {point_x, _} = Integer.parse(str_x)
        {point_y, _} = Integer.parse(str_y)
        point = %Point{x: point_x, y: point_y}
        point
    end

    def point_eq(p1, p2) do
        p1.x == p2.x and p1.y == p2.y
    end
end

defmodule Line do
   defstruct [:p1, :p2]

    def slope(l) do
        if l.p1.x == l.p2.x do
            nil
        else 
            (l.p1.y - l.p2.y)/(l.p1.x - l.p2.x)
        end
    end

    
    def y_intercept(l) do
        if l.p1.x == l.p2.x do
            nil
        else
            l.p1.y - (slope(l) * l.p1.x)
        end
    end

    def goes_over_point(l, p) do
        ((l.p1.x <= p.x and p.x <= l.p2.x) or (l.p2.x <= p.x and p.x <= l.p1.x)) and
        ((l.p1.y <= p.y and p.y <= l.p2.y) or (l.p2.y <= p.y and p.y <= l.p1.y)) and
        (slope(l) == nil or y_intercept(l) + slope(l) * p.x == p.y)
    end

    def get_intersections(a, b) do
        possible_intersection_points = cond do
        slope(a) == slope(b) ->
            # Ugly hack: Just give every point as possible and let the filter at the bottom
            # fix it
            cond do
            slope(a) == nil and a.p1.x == b.p1.x -> 
                (Enum.to_list(a.p1.y .. a.p2.y) ++ Enum.to_list(a.p1.y .. a.p2.y)) 
                |> Enum.uniq
                |> Stream.map(fn (y) -> %Point{x: a.p1.x, y: y} end)
                |> Enum.to_list
            slope(a) != nil && y_intercept(a) == y_intercept(b) -> 
                (Enum.to_list(a.p1.x .. a.p2.x) ++ Enum.to_list(a.p1.x .. a.p2.x)) 
                |> Enum.uniq
                |> Stream.map(fn (x) -> %Point{x: x, y: (y_intercept(b) + slope(b) * x)} end)
                |> Enum.to_list
            true -> []
            end
        slope(a) == nil -> 
            [%Point{x: a.p1.x, y: y_intercept(b) + a.p1.x*slope(b)}]
        slope(b) == nil ->
            [%Point{x: b.p1.x, y: y_intercept(a) + b.p1.x*slope(a)}]
        true ->
            intersection_x = (y_intercept(b) - y_intercept(a))/(slope(a) - slope(b))
            [%Point{x: intersection_x, y: trunc(y_intercept(a) + intersection_x * slope(a))}]
        end
        possible_intersection_points 
            |> Enum.filter(fn (intersection_point)  ->
                goes_over_point(a, intersection_point) && goes_over_point(b, intersection_point)
            end) 
            # It's ugly that some of the values are ints and some are floats, so I'll just make sure they
            # are all floats at the end
            |> Enum.map(fn (p) -> %Point{x: p.x / 1, y: p.y / 1} end)
    end
    

    def parse_line(str) do
        [str1, str2] = String.split(str, " -> ")
        %Line{p1: Point.parse_point(str1), p2: Point.parse_point(str2)}
    end
end

defmodule LineTest do
  use ExUnit.Case

  test "calculates slope" do
    assert Line.slope(%Line{p1: %Point{x: 5, y: 5}, p2: %Point{x: 1, y: 1}}) == 1
    assert Line.slope(%Line{p1: %Point{x: 5, y: 5}, p2: %Point{x: 1, y: 9}}) == -1
    assert Line.slope(%Line{p1: %Point{x: 5, y: 9}, p2: %Point{x: 1, y: 1}}) == 2
  end
  
  test "calculates y-intercept" do
    assert Line.y_intercept(%Line{p1: %Point{x: 5, y: 5}, p2: %Point{x: 1, y: 1}}) == 0
    assert Line.y_intercept(%Line{p1: %Point{x: 5, y: 5}, p2: %Point{x: 1, y: 9}}) == 10
    assert Line.y_intercept(%Line{p1: %Point{x: 5, y: 9}, p2: %Point{x: 1, y: 1}}) == -1
  end
  test "determines go-over" do
    assert Line.goes_over_point(%Line{p1: %Point{x: 5, y: 5}, p2: %Point{x: 1, y: 1}}, %Point{x: 3, y: 3})
    assert !Line.goes_over_point(%Line{p1: %Point{x: 5, y: 5}, p2: %Point{x: 1, y: 1}}, %Point{x: 10, y: 3})
    assert Line.goes_over_point(%Line{p1: %Point{x: 5, y: 5}, p2: %Point{x: 1, y: 1}}, %Point{x: 1, y: 1})
    assert !Line.goes_over_point(%Line{p1: %Point{x: 5, y: 5}, p2: %Point{x: 1, y: 1}}, %Point{x: 10, y: 1})
    assert Line.goes_over_point(%Line{p1: %Point{x: 5, y: 5}, p2: %Point{x: 1, y: 1}}, %Point{x: 5, y: 5})
  end
  test "determines normal intersections" do
    [first_intersect] = Line.get_intersections(%Line{p1: %Point{x: 5, y: 5}, p2: %Point{x: 1, y: 1}}, 
                              %Line{p1: %Point{x: 1, y: 5}, p2: %Point{x: 5, y: 1}})
    assert first_intersect.x == 3
    assert first_intersect.y == 3
  end
  test "determines horizontal intersections" do
    [second_intersect] = Line.get_intersections(%Line{p1: %Point{x: 5, y: 10}, p2: %Point{x: 0, y: 0}}, 
                              %Line{p1: %Point{x: 1, y: 4}, p2: %Point{x: 5, y: 4}})
    assert second_intersect.x == 2
    assert second_intersect.y == 4
  end
  test "determines vertical intersections" do
    [third_intersect] = Line.get_intersections(%Line{p1: %Point{x: 5, y: 10}, p2: %Point{x: 0, y: 0}}, 
                              %Line{p1: %Point{x: 3, y: 4}, p2: %Point{x: 3, y: 8}})
    assert third_intersect.x == 3
    assert third_intersect.y == 6
  end
  test "determines single point intersections" do
    [fourth_intersect] = Line.get_intersections(%Line{p1: %Point{x: 1, y: 6}, p2: %Point{x: 10, y: 6}}, 
                              %Line{p1: %Point{x: 3, y: 6}, p2: %Point{x: 3, y: 6}})
    assert fourth_intersect.x == 3
    assert fourth_intersect.y == 6
  end
  test "determines single point on angle intersections" do
    [fifth_intersect] = Line.get_intersections(%Line{p1: %Point{x: 0, y: 0}, p2: %Point{x: 5, y: 10}}, 
                              %Line{p1: %Point{x: 3, y: 6}, p2: %Point{x: 3, y: 6}})
    assert fifth_intersect.x == 3
    assert fifth_intersect.y == 6
  end
  test "determines multi point on vertical lines" do
    [first_intersection, second_intersection] = Line.get_intersections(
        %Line{p1: %Point{x: 1, y: 0}, p2: %Point{x: 1, y: 3}}, 
        %Line{p1: %Point{x: 1, y: 2}, p2: %Point{x: 1, y: 4}})
    assert first_intersection.x == 1
    assert first_intersection.y == 2
    assert second_intersection.x == 1
    assert second_intersection.y == 3
  end
  test "determines multi point on horizontal lines" do
    [first_intersection, second_intersection] = Line.get_intersections(
        %Line{p1: %Point{x: 0, y: 1}, p2: %Point{x: 3, y: 1}}, 
        %Line{p1: %Point{x: 4, y: 1}, p2: %Point{x: 2, y: 1}})
    assert first_intersection.x == 2
    assert first_intersection.y == 1
    assert second_intersection.x == 3
    assert second_intersection.y == 1
  end
  test "determines multi point on angled lines" do
    [first_intersection, second_intersection] = Line.get_intersections(
        %Line{p1: %Point{x: 3, y: 3}, p2: %Point{x: 0, y: 0}}, 
        %Line{p1: %Point{x: 2, y: 2}, p2: %Point{x: 4, y: 4}})
    assert first_intersection.x == 3
    assert first_intersection.y == 3
    assert second_intersection.x == 2
    assert second_intersection.y == 2
  end
  test "parse line" do
    assert Line.parse_line("769,784 -> 662,784").p1.x == 769
    assert Line.parse_line("769,784 -> 662,784").p1.y == 784
    assert Line.parse_line("769,784 -> 662,784").p2.x == 662
    assert Line.parse_line("769,784 -> 662,784").p2.y == 784
  end
end

defmodule Solutions do
    def p1 do
        lines = File.stream!("input.txt") 
        |> Stream.map(fn (line_str) -> Line.parse_line(String.trim(line_str)) end)
        |> Stream.filter(fn (line) -> Line.slope(line) == nil or Line.slope(line) == 0 end)

        intersections = lines
        |> Stream.with_index
        |> Stream.flat_map(fn ({line1, index}) -> Enum.drop(lines, index + 1) 
            |> Stream.map(fn (line2) -> {line1, line2, Line.get_intersections(line1, line2)} end) end)
        |> Stream.flat_map(fn ({l1, l2, intersections}) -> intersections |> Stream.map(fn (i) -> {l1, l2, i} end) end)
        |> Stream.filter(fn ({_, _, intersection}) -> intersection != nil end)
        |> Enum.uniq_by(fn ({_, _, intersection}) -> intersection end)

        IO.puts Enum.count(Enum.to_list(intersections))
    end
    def p2 do
        lines = File.stream!("input.txt") 
        |> Stream.map(fn (line_str) -> Line.parse_line(String.trim(line_str)) end)

        intersections = lines
        |> Stream.with_index
        |> Stream.flat_map(fn ({line1, index}) -> Enum.drop(lines, index + 1) 
            |> Stream.map(fn (line2) -> {line1, line2, Line.get_intersections(line1, line2)} end) end)
        |> Stream.flat_map(fn ({l1, l2, intersections}) -> intersections |> Stream.map(fn (i) -> {l1, l2, i} end) end)
        |> Stream.filter(fn ({_, _, intersection}) -> intersection != nil end)
        |> Enum.uniq_by(fn ({_, _, intersection}) -> intersection end)

        IO.puts Enum.count(Enum.to_list(intersections))
    end
end

Solutions.p1
Solutions.p2