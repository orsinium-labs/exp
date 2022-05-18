defmodule Inline do
  @moduledoc """
  Documentation for `Inline`.
  """

  @doc """
  Macro that statically executes and inlines the passed argument at compile time.
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
    {:node, 1},
    {:binary_part, 3},
    {:bit_size, 1},
    {:byte_size, 1},
    {:size, 1},
    {:div, 2},
    {:rem, 2},
    {:node, 0},
    {:self, 0},
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
  @pure_modules [Integer, Float, Kernel, Atom, Base, Bitwise, String, Tuple, URI, Version]

  @doc """
  Check if the function of given name and arity is pure.
  """
  @spec pure_func?(atom(), pos_integer()) :: boolean()
  def pure_func?(name, arity)

  Enum.each(@pure_funcs, fn {name, arity} ->
    def pure_func?(unquote(name), unquote(arity)), do: true
  end)

  def pure_func?(_, _), do: false

  @doc """
  Check if the function of given module, name, and arity is pure.
  """
  @spec pure_func?(atom(), atom(), pos_integer()) :: boolean()
  def pure_func?(module_name, function_name, arity)

  Enum.each(@pure_modules, fn module_name ->
    def pure_func?(unquote(module_name), _, _), do: true
  end)

  def pure_func?(:Kernel, name, arity), do: pure_func?(name, arity)
  def pure_func?(:erlang, name, arity), do: pure_func?(name, arity)
  def pure_func?(_, _, _), do: false

  @doc """
  Check if the given AST node is safe to be statically executed.

  This check is conservative. If it doesn't know anything about the function,
  the answer is "no".
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
  are safe to execute at compile time.
  """
  defmacro maybe_inline(block) do
    params = Enum.flat_map(Macro.prewalker(block), &get_unquote/1)

    quote generated: true do
      if safe_node?(unquote(params)) do
        {term, _} = unquote(block) |> Code.eval_quoted()
        Macro.escape(term)
      else
        unquote(block)
      end
    end
  end

  @spec abs(Macro.t()) :: Macro.t()
  defmacro abs(n) do
    maybe_inline(quote(do: abs(unquote(n))))
  end

  @spec to_charlist(Macro.t()) :: Macro.t()
  defmacro to_charlist(str) do
    maybe_inline(quote(do: Kernel.to_charlist(unquote(str))))
  end

  @spec to_string(Macro.t()) :: Macro.t()
  defmacro to_string(str) do
    maybe_inline(quote(do: Kernel.to_string(unquote(str))))
  end
end
