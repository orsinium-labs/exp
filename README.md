# Inline

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
require Inline
rex = Inline.inline(Regex.compile!("[0-9]+"))
```

**Documentation**: [hexdocs.pm/inline](https://hexdocs.pm/inline/Inline.html).
