defmodule STest do
  use ExUnit.Case
  doctest S

  describe "inline" do
    test "runtime" do
      assert S.inline(String.upcase("hello")) == "HELLO"
    end

    test "compile time" do
      q = quote do: S.inline(String.upcase("hello"))
      assert Macro.expand(q, __ENV__) == "HELLO"
    end
  end

  describe "abs" do
    test "runtime" do
      assert S.abs(-13) == 13
      assert S.abs(13) == 13
    end

    test "variable" do
      var = -13
      assert S.abs(var) == 13
    end

    test "compile time" do
      q = quote do: S.abs(13)
      assert Macro.expand(q, __ENV__) == 13
    end
  end
end
