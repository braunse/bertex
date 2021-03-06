defmodule Bertex.Test do
  use ExUnit.Case
  import Bertex
  import :erlang, only: [binary_to_term: 1, term_to_binary: 1]

  doctest Bertex

  defp assert_term(term) do
    assert decode(encode(term)) == term
  end

  test "encode true" do
    assert binary_to_term(encode(true)) == {:bert, true}
  end

  test "encode false" do
    assert binary_to_term(encode(false)) == {:bert, false}
  end

  test "encode integer" do
    assert binary_to_term(encode(1)) == 1
  end

  test "encode float" do
    assert binary_to_term(encode(3.14)) == 3.14
  end

  test "encode binary" do
    assert binary_to_term(encode("binary string")) == "binary string"
  end

  test "encode UTF-8 string" do
    assert binary_to_term(encode("été")) == "été"
    assert encode("été") == <<131, 109, 0, 0, 0, 5, 195, 169, 116, 195, 169>>
  end

  test "encode atom" do
    assert binary_to_term(encode(:atom)) == :atom
  end

  test "encode nil" do
    assert binary_to_term(encode(nil)) == {:bert, nil}
  end

  test "encode list" do
    assert binary_to_term(encode([1, 2, 3])) == [1, 2, 3]
  end

  test "encode map" do
    dict = %{}
      |> Map.put(:key, "value")
    assert binary_to_term(encode(dict)) == %{key: "value"}
  end

  test "decode true" do
    assert decode(term_to_binary({:bert, true})) == true
  end

  test "decode false" do
    assert decode(term_to_binary({:bert, false})) == false
  end

  test "decode integer" do
    assert decode(term_to_binary(1)) == 1
  end

  test "decode float" do
    assert decode(term_to_binary(3.14)) == 3.14
  end

  test "decode binary" do
    assert decode(term_to_binary("binary string")) == "binary string"
  end

  test "decode atom" do
    assert decode(term_to_binary(:atom)) == :atom
  end

  test "decode nil" do
    assert decode(term_to_binary({:bert, nil})) == nil
  end

  test "decode list" do
    assert decode(term_to_binary([1, 2, 3])) == [1, 2, 3]
  end

  test "decode map" do
    dict = %{}
      |> Map.put(:key, "value")
    assert decode(term_to_binary(%{key: "value"})) == dict
  end

  test "encode/decode true" do
    assert_term(true)
  end

  test "encode/decode false" do
    assert_term(false)
  end

  test "encode/decode integer" do
    assert_term(1)
  end

  test "encode/decode float" do
    assert_term(1.1)
  end

  test "encode/decode binary" do
    assert_term("binary text")
  end

  test "encode/decode list of integers" do
    assert_term([1, 2, 3])
  end

  test "encode/decode a dict" do
    assert_term([{'a', :b}])
  end

  test "encode/decode empty list" do
    assert_term([])
  end

  test "encode/decode complex list" do
    assert_term([1,2,3, false, true, {"e", "f"}])
  end

  test "encode/decode a map" do
    %{} |> Map.put(:hello, "world")
        |> assert_term
  end

  test "safely decode a known atom" do
    assert safe_decode(encode(:known_atom)) == :known_atom
  end

  test "safely decode an atom" do
    # :unknown_atom
    binary_rep_to_unknown_atom = <<131,100,0,12,117,110,107,110,111,119,110,95,97,116,111,109>>
    assert_raise ArgumentError,  fn -> safe_decode(binary_rep_to_unknown_atom) end
  end

  test "encode naive date time" do
    {:ok, date} = NaiveDateTime.new(2009, 10, 11, 14, 12, 1, {0, 6})
    assert binary_to_term(encode(date)) == {:bert, :time, 1255, 270321, 0}
  end

  test "encode date time" do
    {:ok, naive} = NaiveDateTime.new(2009, 10, 11, 14, 12, 1, {0, 6})
    {:ok, date} = DateTime.from_naive(naive, "Etc/UTC")
    assert binary_to_term(encode(date)) == {:bert, :time, 1255, 270321, 0}
  end

  test "encode date" do
    {:ok, date} = Date.new(2009, 10, 11)
    assert binary_to_term(encode(date)) == {:bert, :time, 1255, 219200, 0}
  end

  test "decode date time" do
    {:ok, naive} = NaiveDateTime.new(2009, 10, 11, 14, 12, 1, {0, 6})
    {:ok, date} = DateTime.from_naive(naive, "Etc/UTC")
    assert decode(term_to_binary({:bert, :time, 1255, 270321, 0})) == date
  end

  test "refuses to encode a function" do
    catch_error(encode(fn x -> x end))
  end

  test "refuses to decode a function" do
    catch_error(decode(term_to_binary(fn x -> x + 1 end)))
  end
end
