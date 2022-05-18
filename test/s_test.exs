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

  # describe "maybe_inline" do
  #   test "runtime" do
  #     assert S.maybe_inline(String.upcase("hello")) == "HELLO"
  #   end

  #   test "compile time" do
  #     q = quote do: S.maybe_inline(String.upcase("hello"))
  #     assert Macro.expand(q, __ENV__) == "HELLO"
  #   end

  #   test "variable runtime" do
  #     var = "hello"
  #     assert S.maybe_inline(String.upcase(var)) == "HELLO"
  #   end
  # end

  describe "compile_regex" do
    test "runtime" do
      assert S.compile_regex("hello") == ~r"hello"
    end

    test "variable" do
      var = "hello"
      assert S.compile_regex(var) == ~r"hello"
    end

    test "compile time" do
      require S
      q = quote do: S.compile_regex("hello")
      assert Macro.expand(q, __ENV__) == Macro.escape(~r"hello")
    end
  end
end
