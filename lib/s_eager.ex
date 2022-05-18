defmodule S.Eager do
  use Decorator.Define, eager: 0

  @spec eager(Macro.t(), Decorator.Decorate.Context) :: Macro.t()
  def eager(body, context) do
    quote bind_quoted: [body: body, args: context.args] do
      if Macro.quoted_literal?(args) do
        {term, _} = body |> Code.eval_quoted()
        Macro.escape(term)
      else
        body
      end
    end
  end
end
