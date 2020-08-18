# Elixir
## Summary
Elixir is a functional 
From wikipedia: 
> Elixir is a functional, concurrent, general-purpose programming language that runs on the Erlang virtual machine (BEAM). Elixir builds on top of Erlang and shares the same abstractions for building distributed, fault-tolerant applications

Created by Jose Valim it is completely open source. It is similar to Ruby, Erlang and Clojure. Most of what is below comes directly from the Elixir lang getting started tutorial. To check out Elixir more and for more in detail I highly recommend it.

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

### Immutable Data
>List operators never modify the existing list. Concatenating to or removing elements from a list returns a new list. We say that Elixir data structures are immutable.

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

## Modules and Functions

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

## Module Example: `KeyValueStore`

## Sources
Offical [Elixir lang getting started](https://elixir-lang.org/getting-started/introduction.html).

More on [Tail Call recursion](https://en.wikipedia.org/wiki/Tail_call).

Excellent [Honeypot Documentary](https://www.youtube.com/watch?v=lxYFOM3UJzo) on Elixir.

Image and helpful info from an [awesome blog post.](https://blog.lelonek.me/elixir-on-erlang-vm-demystified-320557d09e1f)

[Wikipedia article](https://en.wikipedia.org/wiki/Elixir_(programming_language)) on Elixir.
