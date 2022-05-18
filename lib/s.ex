defmodule S do
  @moduledoc """
  Documentation for `S`.
  """
  use S.Eager

  @decorate eager()
  @spec compile_regex(Macro.t()) :: Macro.t()
  defmacro compile_regex(source) do
    quote bind_quoted: [source: source] do
      Regex.compile!(source)
    end
  end
end
