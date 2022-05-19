defmodule Inline do
  @moduledoc """
  Macro to execute and inline expressions at compile time.

  * In a regular code, all you need is `Inline.inline/1`.
  * For usage inside of macros when you don't know if arguments are safe,
    see `Inline.maybe_inline/1`.
  * `Inline.abs/1` is a real-world example of using `Inline.maybe_inline/1`.
  * `Inline.pure_func?/3` and `Inline.safe_node?/1` are utility function that
    `Inline.maybe_inline/1` uses to make decision if expression is safe to inline.

  """

  @doc """
  Macro that statically executes and inlines the passed argument at compile time.

  If the expression cannot be inlined, it will explode at compile time.
  This is your responsibility to make sure the code can be inlined and is safe to inline.

  ## What to inline

  There are requirements for a good candidate to be inlined:

  * It doesn't make network requests.
  * It doesn't depend on a service or ecto.
  * For the same input, it always produces the same output.
  * It's not too slow.
  * Its result doesn't take too much memory.

  A good example of such function is `Regex.compile!/2`.

  ## Examples

  The usage is straightforward, just wrap whatever you want to inline:

      iex> require Inline
      iex> Inline.inline(1 + 2)
      3

  The difference is that the expression inside will be executed at compile time
  (when expanding the AST) and included into the compiled code:

      iex(21)> q = quote do: 1 + 2
      iex(22)> {:+, _, [1, 2]} = Macro.expand(q, __ENV__)
      iex(23)> q = quote do: Inline.inline(1 + 2)
      iex(24)> 3 = Macro.expand(q, __ENV__)

  """
  @spec inline(Macro.t()) :: Macro.t()
  defmacro inline(call) do
    {term, _} = Code.eval_quoted(call)
    Macro.escape(term)
  end

  # list of pure BIFs
  @pure_funcs [
    {:is_atom, 1},
    {:is_binary, 1},
    {:is_bitstring, 1},
    {:is_boolean, 1},
    {:is_float, 1},
    {:is_function, 1},
    {:is_function, 2},
    {:is_integer, 1},
    {:is_list, 1},
    {:is_map, 1},
    {:is_map_key, 2},
    {:is_number, 1},
    {:is_pid, 1},
    {:is_port, 1},
    {:is_reference, 1},
    {:is_tuple, 1},
    {:<, 2},
    {:"=<", 2},
    {:>, 2},
    {:>=, 2},
    {:"/=", 2},
    {:"=/=", 2},
    {:==, 2},
    {:"=:=", 2},
    {:*, 2},
    {:+, 1},
    {:+, 2},
    {:-, 1},
    {:-, 2},
    {:/, 2},
    {:abs, 1},
    {:ceil, 1},
    {:floor, 1},
    {:round, 1},
    {:trunc, 1},
    {:element, 2},
    {:hd, 1},
    {:length, 1},
    {:map_get, 2},
    {:map_size, 1},
    {:tl, 1},
    {:tuple_size, 1},
    {:binary_part, 3},
    {:bit_size, 1},
    {:byte_size, 1},
    {:size, 1},
    {:div, 2},
    {:rem, 2},
    {:bnot, 1},
    {:band, 2},
    {:bor, 2},
    {:bxor, 2},
    {:bsl, 2},
    {:bsr, 2},
    {:or, 2},
    {:and, 2},
    {:xor, 2},
    {:not, 1},
    {:andalso, 2},
    {:orelse, 2}
  ]
  # List of modules that contain only pure functions
  @pure_modules [
    # basic types
    Atom,
    Base,
    Bitwise,
    Float,
    Integer,
    Kernel,
    String,
    Tuple,
    URI,
    Version,

    # collections
    Access,
    Enum,
    Keyword,
    List,
    Map,
    MapSet,
    Range,
    Stream,

    # popular third-party
    Jason,
    Poison
  ]

  @doc """
  Check if the function of given name and arity is pure.

  ## Examples

      iex> Inline.pure_func?(:abs, 1)
      true
      iex> Inline.pure_func?(:abs, 2)  # bad arity
      false
      iex> Inline.pure_func?(:send, 2)
      false

  """
  @spec pure_func?(atom(), non_neg_integer()) :: boolean()
  def pure_func?(name, arity)

  Enum.each(@pure_funcs, fn {name, arity} ->
    def pure_func?(unquote(name), unquote(arity)), do: true
  end)

  def pure_func?(_, _), do: false

  @doc """
  Check if the function of given module, name, and arity is pure.

  ## Examples

      iex> Inline.pure_func?(String, :upcase, 1)
      true
      iex> Inline.pure_func?(String, :upcase, 4) # bad arity
      false
      iex> Inline.pure_func?(File, :cwd, 0)
      false
      iex> Inline.pure_func?(Kernel, :abs, 1)
      true
      iex> Inline.pure_func?(:erlang, :abs, 1)
      true
  """
  @spec pure_func?(atom(), atom(), non_neg_integer()) :: boolean()
  def pure_func?(module, function, arity)

  Enum.each(@pure_modules, fn module ->
    def pure_func?(m = unquote(module), f, a),
      do: Code.ensure_loaded?(m) and function_exported?(m, f, a)
  end)

  def pure_func?(:Kernel, name, arity), do: pure_func?(name, arity)
  def pure_func?(:erlang, name, arity), do: pure_func?(name, arity)
  def pure_func?(_, _, _), do: false

  @doc """
  Check if the given AST node is safe to be statically executed.

  This check is conservative. If it doesn't know anything about the function,
  the result is `false`.

  It's used be `Inline.maybe_inline/1` to make a decision if the code should be inlined.

  ## Examples

      iex> Inline.safe_node?(quote do: 1)
      true
      iex> Inline.safe_node?(quote do: "hello")
      true
      iex> Inline.safe_node?(quote do: 1+2)
      true
      iex> Inline.safe_node?(quote do: div(2, 3))
      true
      iex> Inline.safe_node?(quote do: File.cwd())
      false
  """
  @spec safe_node?(Macro.t()) :: boolean()
  def safe_node?(term)
  def safe_node?({:__aliases__, _, args}), do: safe_node?(args)
  def safe_node?({:%, _, [left, right]}), do: safe_node?(left) and safe_node?(right)
  def safe_node?({:%{}, _, args}), do: safe_node?(args)
  def safe_node?({:{}, _, args}), do: safe_node?(args)
  def safe_node?({left, right}), do: safe_node?(left) and safe_node?(right)
  def safe_node?(list) when is_list(list), do: Enum.all?(list, &safe_node?/1)

  def safe_node?({{:., _, [{_, _, [mname]}, fname]}, [], list}) when is_list(list),
    do: pure_func?(mname, fname, length(list)) and safe_node?(list)

  def safe_node?({fname, _, list}) when is_list(list),
    do: pure_func?(fname, length(list)) and safe_node?(list)

  def safe_node?(term), do: is_atom(term) or is_number(term) or is_binary(term)

  defp get_unquote({:unquote, _, [expr]}), do: [expr]
  defp get_unquote(_), do: []

  @doc """
  A safe implementation of `inline/1` for macros.

  It inlines the given quoted expression if and only if all `unquote` arguments
  are safe to execute at compile time. The safety of the expression itself isn't checked.
  The result is also a quoted expression.

  It's supposed to be used from macros when you don't know if the macros
  will be used for a safe to execute code or not.


  ## Examples

  Here, `var` is safe and so the expression is inlined:

      iex> var = quote do: 13
      iex> 13 = Inline.maybe_inline(quote do: abs(unquote(var)))

  Here, `var` is not safe and so the expression is left as-is:

      iex> var = quote do: node()
      iex> {:abs, _, _} = Inline.maybe_inline(quote do: abs(unquote(var)))

  Here, the expression isn't safe but it's still inlined because `maybe_inline/2`
  checks only safety of expressions inside `Kernel.SpecialForms.unquote/1`:

      iex> Inline.maybe_inline(quote do: node())
      :nonode@nohost

  See also `Inline.abs/1` for a real-world usage example.
  """
  @spec maybe_inline(Macro.t()) :: Macro.t()
  defmacro maybe_inline(block) do
    params = Enum.flat_map(Macro.prewalker(block), &get_unquote/1)

    quote generated: true do
      if Inline.safe_node?(unquote(params)) do
        {term, _} = unquote(block) |> Code.eval_quoted()
        Macro.escape(term)
      else
        unquote(block)
      end
    end
  end

  @doc """
  Inlined version of `Kernel.abs/1`.

  Returns the arithmetical absolute value of the `number`.

  ## Examples

      iex> Inline.abs(-2)
      2
      iex> Inline.abs(2)
      2

  This is how you can check if it was inlined:

      iex> # inlined:
      iex> q = quote do: Inline.abs(-2)
      iex> 2 = Macro.expand(q, __ENV__)
      iex> # not inlined because unsafe:
      iex> q = quote do: Inline.abs(node())
      iex> {:abs, _, _} = Macro.expand(q, __ENV__)

  """
  @spec abs(Macro.t()) :: Macro.t()
  defmacro abs(number) do
    maybe_inline(quote(do: abs(unquote(number))))
  end

  @doc false
  @spec to_charlist(Macro.t()) :: Macro.t()
  defmacro to_charlist(str) do
    maybe_inline(quote(do: Kernel.to_charlist(unquote(str))))
  end

  @doc false
  @spec to_string(Macro.t()) :: Macro.t()
  defmacro to_string(str) do
    maybe_inline(quote(do: Kernel.to_string(unquote(str))))
  end
end
