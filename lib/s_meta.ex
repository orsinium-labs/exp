defmodule S.Meta do
  @moduledoc """
  Documentation for `S`.
  """

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :eager, accumulate: true)
      Module.register_attribute(__MODULE__, :eager_funcs, accumulate: true)
      @before_compile {S.Meta, :before_compile}
      @on_definition {S.Meta, :on_definition}
    end
  end

  def on_definition(env, kind, name, args, guards, body) do
    if kind == :def or kind == :defp do
      is_eager = Module.get_attribute(env.module, :eager)

      if length(is_eager) > 0 do
        Module.put_attribute(env.module, :eager_funcs, {kind, name, args, guards, body})
        Module.delete_attribute(env.module, :eager)
      end
    end
  end

  defmacro before_compile(env) do
    eager_funcs = Module.get_attribute(env.module, :eager_funcs)
    Module.delete_attribute(env.module, :eager_funcs)
    Module.delete_attribute(env.module, :eager)
    eager_funcs |> Enum.map(&make_eager/1)
  end

  defp make_eager({kind, name, args, _guards, body}) do
    IO.inspect body 

    quote do
      Kernel.unquote(kind)(
        unquote(name)(unquote_splicing(args)),
        unquote(body)
      )
    end
  end
end
