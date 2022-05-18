defmodule S do
  @moduledoc """
  Documentation for `S`.
  """

  defmacro inline(call) do
    {term, _} = Code.eval_quoted(call)
    Macro.escape(term)
  end

  defmacrop maybe_inline(params, do: block) do
    quote generated: true do
      if Macro.quoted_literal?(unquote(params)) do
        {term, _} = unquote(block) |> Code.eval_quoted()
        Macro.escape(term)
      else
        unquote(block)
      end
    end
  end

  @spec compile_regex(Macro.t()) :: Macro.t()
  defmacro compile_regex(source) do
    maybe_inline [source] do
      quote generated: true do
        Regex.compile!(unquote(source))
      end
    end
  end

  @spec unescape_string(Macro.t()) :: Macro.t()
  defmacro unescape_string(str) do
    quote bind_quoted: [str: str] do
      require S
      S.maybe_inline(Macro.unescape_string(str))
    end
  end
end
