defmodule STest do
  use ExUnit.Case
  doctest S

  describe "compile_regex" do
    test "runtime" do
      assert S.compile_regex("hello") == ~r"hello"
    end

    test "variable" do
      var = "hello"
      assert S.compile_regex(var) == ~r"hello"
    end

    test "compile time" do
      q = quote do: S.compile_regex("hello")
      assert Macro.expand(q, __ENV__) == Macro.escape(~r"hello")
    end
  end
end
