# Elixir
## Summary
From wikipedia: 
> Elixir is a functional, concurrent, general-purpose programming language that runs on the Erlang virtual machine (BEAM). Elixir builds on top of Erlang and shares the same abstractions for building distributed, fault-tolerant applications.

Created by Jose Valim it is completely open source. It is similar to Ruby, Erlang and Clojure. Most of what is below comes directly from the Elixir language getting started tutorial. To check out Elixir more and for more in detail I highly recommend it.

Let's dive in!

## Types and Operators
### Basic Types
Here are some basic types:
  - `integer`
  - `float`
  - `boolean`
  - `atom/symbol`
  - `string`
  - `list`
  - `tuple`

Let's use Interactive Elixir `iex` to try them out!

Examples:
```
# My first comment
40 + 2
2 * 3
10 / 2 # division operator always returns float
10 / 2 == 5
10 / 2 === 5 # triple equals requires both to be int or float
IO.puts("hello world")
"hello" <> "world"
# "An atom is a constant whose value is its own name. Some other languages call these symbols. They are often useful to enumerate over distinct values"
:atom
# true, false and nil are simply atoms
true == :true
is_atom(:alpha)
is_atom(false)
```

### Lists
>Elixir uses square brackets to specify a list of values. Values can be of any type. Two lists can be concatenated or subtracted using the `++/2` and `--/2` operators respectively.

_The `/2` denotes the 'arity' or number of parameters an Elixir function takes._

```
[1, 2, true, 3]
length [1, 2, 3] # you can omit parens on function calls
["hello"] ++ ["world"]
[1, true, 2, false, 3, true] -- [true, false]
[1, true, 2, false, 3, true] -- [1, 2, 3]
```
The functions `hd/1` and `tl/1` can grab the head (first element) and tail (second element) of a list.
```
list = [1, 2, 3]
hd(list)
tl(list)
```

### Immutable Data
>List operators never modify the existing list. Concatenating to or removing elements from a list returns a new list. We say that Elixir data structures are immutable.

```
list = [1, 2]
list ++ [3]
list
List.delete(list, 1)
list
List.insert_at(list, 2, 3)
l
```
Putting the data structure as the first parameter is very common allows for methods to chain with the `|>` pipe operator. The pipe operator passes the result of the left side into the right side as the first argument.
```
list = []
list = List.insert_at(list, 0, 1) |>
  List.insert_at(0, 2) |>
  List.insert_at(0, 3) |>
  List.insert_at(0, 4) |>
  List.insert_at(0, 5)
```
### Maps
> Whenever you need a key-value store, maps are the “go to” data structure in Elixir. A map is created using the %{} syntax
```
is_map(%{})
is_map(%{"hello" => "world"})
map = %{"hello" => "world"}
map["hello"]
"world"
# if atoms are the key then you can use . notation
map = %{:alpha => "first", :beta => "second"} 
map.alpha
map.beta

# remember that data is immutable
Map.put(map, :gamma, "third") 
map
modded_map = Map.put(map, :gamma, "third")
modded_map

# You can arbitrarily nest data structures
complex_map = %{
    :names => ["Larry", "Mo", "Curly"],
    :inner_map => %{
        "hello" => "world",
        :answer => 42
    }
}
```

### `case`, `cond` and `if`
`case` is very similar to a `switch` statement from `C#`. 
```
case 5 do
  5 ->
    "matched!"
  6 ->
    "didn't match"
  _ ->
    "catch all if above didn't match"
end

# you can use guard clauses
case {1, 2, 3} do
  {1, x, 3} when x > 0 ->
    "Will match"
  _ ->
    "Would match, if guard condition were not satisfied"
end
```
Notice how the guard returns the result of the matched block? You can assign this with `=`.

`cond` executes the first condition that is not `nil` or `false`.
```
cond do
  2 + 2 == 5 ->
    "This will not be true"
  2 * 2 == 3 ->
    "Nor this"
  1 + 1 == 2 ->
    "But this will"
end
```
Note `cond` considers any values aside from `nil` and `false` to be `true`.

`if` is just what you'd expect.

## Modules and Functions
In Elixir functions are grabbed together in modules. `defmodule` is used to write a module, and `def` or `defp` to write a function. (`defp` is private). The last statement of the function, or executing clause, is the 'return' value for that function.

```
defmodule Math do
  def sum(a, b) do
    a + b
  end
end
```

### Anonymous Functions
>Elixir also provides anonymous functions. Anonymous functions allow us to store and pass executable code around as if it was an integer or a string. They are delimited by the keywords fn and end.

```
add = fn a, b -> a + b end
# . is used between function name and parens to indicate that it is anonymous
add.(1, 2)
is_function(add)
```

### Tail Call Recursion
Simple counter:
```
defmodule Looper do
  # this is called if when guard evaluates to true
  def count(i) when i <= 0 do
    IO.puts("#{i}. That's it, all done counting!")
  end
  def count(i) do
    IO.puts("#{i} let's keep counting down.")
    count(i - 1)
  end
end
```

## Processes in BEAM VM
BEAM stands for Bogdan/Björn’s Erlang Abstract Machine. See diagram below for high level architecture overview.

### BEAM Architecture
![BEAM Architecture](.\BEAM_scheduler.png)

## Message Passing
### PIDs, `self()` and `receive`
Each of those BEAM VM processes has a `PID`. The `PID` can be used to send messages, which can be any Elixir term, to the process.
```
self()
send(self(), "hello there!!!")
flush

send(self(), :hello)
receive do
  :hello -> "hello!"
  :bye -> "goodbye"
end
```

### `spawn`
`spawn` is used to create a new process and execute the zero-arity function that is given to it.

```
spn = spawn(fn ->
  receive do
    {:hello, pid} -> send(pid, "hello to you too!")
  end
end)
Process.alive?(spn)
send(spn, {:hello, self()})
Process.alive?(spn)
flush
```

## Module Example: `KeyValueStore`
Let's check out an example module.

## Sources
Offical [Elixir lang getting started](https://elixir-lang.org/getting-started/introduction.html).

More on [Tail Call recursion](https://en.wikipedia.org/wiki/Tail_call).

Excellent [Honeypot Documentary](https://www.youtube.com/watch?v=lxYFOM3UJzo) on Elixir.

Image and helpful info from an [awesome blog post.](https://blog.lelonek.me/elixir-on-erlang-vm-demystified-320557d09e1f)

[Wikipedia article](https://en.wikipedia.org/wiki/Elixir_(programming_language)) on Elixir.
