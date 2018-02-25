defmodule Zeam do
  @moduledoc """
  Zeam is a module of ZEAM. ZEAM is ZACKY's Elixir Abstract Machine, which is aimed at being BEAM compatible.
  Zeam now provides `dump/1` `dump_p/1` `dump_f/1` `dump_d/1` and `last2/1` functions. 
  """

  @tags [
    SMALL: 15,
    BIG: 11,
    FLOAT: 9,
    ATOM: 7,
    REFER: 6,
    PORT: 5,
    PID: 3,
    TUPLE: 2,
    NIL: (11 + 16), # BIG + 16
    LIST: 1,
    ARITYVAL: 10,
    MOVED: 12,
    CATCH: 13, # THING
    THING: 13,
    BINARY: 14,
    BLANK: 10, # ARITYVAL
    IC: 15, # SMALL
    CP0: 0,
    CP4: 4,
    CP8: 8,
    CP12: 12
  ]

  @doc """
  Hello world.

  ## Examples

      iex> Zeam.hello
      "ZEAM is ZACKY's Elixir Abstract Machine, which is aimed at being BEAM compatible."

  """
  def hello do
    "ZEAM is ZACKY's Elixir Abstract Machine, which is aimed at being BEAM compatible."
  end

  @doc """
  This converts a binary into a list.

  ## Parameter

  - binary: is a binary to convert into a list.

  ## Examples

    iex> Zeam.bin2list(<<0, 1, 2, 3>>)
    [0, 1, 2, 3]

  """
  @spec bin2list(binary) :: list
  def bin2list(binary) do
    case binary do
      <<>> -> :ok
      <<x :: integer>> -> [x]
      <<x :: integer, y :: binary>> -> [x] ++ bin2list(y)
    end
  end 

  @doc """
  This bundles three values away from each value of a list.

  ## Parameter

  - list: is a list to bundle.

  ## Examples

    iex> Zeam.bundle3Values([0, 1, 2, 3])
    [[0, 1, 2], [1, 2, 3]]
  """
  @spec bundle3Values(list) :: list
  def bundle3Values(list) do
    case list do
      [] -> []
      [a] -> []
      [a, b] -> []
      [a, b, c] -> [[a, b, c]]
      [a, b, c | r] -> [[a, b, c]] ++ bundle3Values([b, c] ++ r)
    end
  end

  @doc """
  This concats a list of integer in the manner of little endian.

  ## Parameter

  - list: is a list of integer to concat


  ## Examples

    iex> Integer.to_string(Zeam.concatLittleEndian([0, 1, 2]), 16)
    "20100"
  """
  @spec concatLittleEndian(list) :: integer
  def concatLittleEndian(list) do
    case list do
      [] -> 0
      [a] -> a
      [a | r] -> a + concatLittleEndian(r) * 256
    end
  end

  @doc """
  This reverse a list.

  ## Parameter

  - list: is a list to reverse

  ## Examples

    iex> Zeam.reverseList([0, 1, 2])
    [2, 1, 0]
  """
  @spec reverseList(list) :: list
  def reverseList(list) do
    case list do
      [] -> []
      [a | r] -> reverseList(r) ++ [a]
    end
  end

  @doc """
  This dumps binary files to stdard output.

  ## Parameter

  - path: is data or a binary file path to dump.

  """
  @spec dump(Path.t()) :: String.t()
  def dump(path) do
    IO.puts dump_p(path)
  end

  @doc """
  This dumps binary files to String.

  ## Parameter

  - path: is data or a binary file path to dump.

  ## Examples

    iex> Zeam.dump_p("./test/sample")
    "41 42 43 44 45 46 47 48\\n49 4A 4B 4C 4D 4E\\n\\n"

  """
  @spec dump_p(Path.t()) :: String.t()
  def dump_p(path) do
    {:ok, file} = File.open path, [:read]
    dump_f(file)
  end

  @doc """
  This dumps binary files to String.

  ## Parameter

  - file: is data or a binary file path to dump.

  """
  @spec dump_f(File.t()) :: String.t()
  def dump_f(file) do
    case IO.binread(file, 8) do
      {:error, reason} -> {:error, reason} 
      :eof -> "\n"
      data -> "#{dump_d(data)}\n#{dump_f(file)}"
    end
  end


  @doc """
  This dumps binary data to String.

  ## Parameters

  - data: is binary data to dump.

  ## Examples

    iex> Zeam.dump_d(<<0, 1, 2, 3>>)
    "00 01 02 03"

  """
  @spec dump_d(binary) :: String.t()
  def dump_d(data) do
    case data do
      <<>> -> :ok
      <<x :: integer>> -> "0#{Integer.to_string(x, 16)}" |> last2  
      <<x :: integer, y :: binary>> -> "#{dump_d(<<x>>)} #{dump_d(y)}"
    end
  end

  @doc """
  This slices the last 2 chars.

  ## Parameters

  - string: is string to slice.

  ## Examples

    iex> Zeam.last2("0123")
    "23"
  """
  @spec last2(String.t()) :: String.t()
  def last2(string) do
    String.slice(string, String.length(string) - 2, String.length(string))
  end  
end
