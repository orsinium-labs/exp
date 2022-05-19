defmodule ExpTest do
  @moduledoc false
  use ExUnit.Case
  doctest Exp

  describe "inline" do
    test "runtime" do
      assert Exp.inline(String.upcase("hello")) == "HELLO"
    end

    test "compile time" do
      q = quote do: Exp.inline(String.upcase("hello"))
      assert Macro.expand(q, __ENV__) == "HELLO"
    end
  end

  describe "abs" do
    test "runtime" do
      assert Exp.abs(-13) == 13
      assert Exp.abs(13) == 13
    end

    test "variable" do
      var = -13
      assert Exp.abs(var) == 13
    end

    test "compile time" do
      q = quote do: Exp.abs(-13)
      assert Macro.expand(q, __ENV__) == 13
    end
  end
end
