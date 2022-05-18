defmodule STest do
  use ExUnit.Case
  doctest Inline

  describe "inline" do
    test "runtime" do
      assert Inline.inline(String.upcase("hello")) == "HELLO"
    end

    test "compile time" do
      q = quote do: Inline.inline(String.upcase("hello"))
      assert Macro.expand(q, __ENV__) == "HELLO"
    end
  end

  describe "abs" do
    test "runtime" do
      assert Inline.abs(-13) == 13
      assert Inline.abs(13) == 13
    end

    test "variable" do
      var = -13
      assert Inline.abs(var) == 13
    end

    test "compile time" do
      q = quote do: Inline.abs(-13)
      assert Macro.expand(q, __ENV__) == 13
    end
  end
end
