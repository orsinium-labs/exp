# Exp

Elixir library to execute and inline expressions at compile time.

## Installation

```elixir
def deps do
  [
    {:inline, "=> 1.0.0"}
  ]
end
```

## Usage

Compile a regular expression at compile time (without using sigils):

```elixir
require Exp
rex = Exp.inline(Regex.compile!("[0-9]+"))
```

**Documentation**: [hexdocs.pm/exp](https://hexdocs.pm/exp/Exp.html).
