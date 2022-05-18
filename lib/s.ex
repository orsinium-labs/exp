defmodule S do
  @moduledoc """
  Documentation for `S`.
  """

  defmacro inline(call) do
    {term, _} = Code.eval_quoted(call)
    Macro.escape(term)
  end

  def get_unquote({:unquote, _, [expr]}), do: [expr]
  def get_unquote(_), do: []

  defmacrop maybe_inline(block) do
    params = Enum.flat_map(Macro.prewalker(block), &get_unquote/1)

    quote generated: true do
      if Macro.quoted_literal?(unquote(params)) do
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

  # @spec unescape_string(Macro.t()) :: Macro.t()
  # defmacro unescape_string(str) do
  #   quote bind_quoted: [str: str] do
  #     require S
  #     S.maybe_inline(Macro.unescape_string(str))
  #   end
  # end
end
