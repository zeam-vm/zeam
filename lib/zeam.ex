use Bitwise

defmodule Zeam do
  @moduledoc """
  Zeam is a module of ZEAM. ZEAM is ZACKY's Elixir Abstract Machine, which is aimed at being BEAM compatible.
  Zeam now provides bytecode analyzing functions. 
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
      <<>> -> []
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
      [_] -> []
      [_, _] -> []
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
  This concats a list of integer in the manner of big endian.

  ## Parameter

  - list: is a list of integer to concat


  ## Examples

    iex> Integer.to_string(Zeam.concatBigEndian([0, 1, 2]), 16)
    "102"
  """
  @spec concatBigEndian(list) :: integer
  def concatBigEndian(list) do
    list |> reverseList |> concatLittleEndian
  end

  @doc """
  This reverses a list.

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
  This reads binary (a sequence of bytes) and generates a list of integers that each value is regarded as a 24 bits (3 bytes) in little endian.

  ## Parameter

  - binary: is a binary to read

  ## Examples

    iex> Zeam.toAddressInLittleEndian(<<0, 1, 2, 3>>)
    [131328, 197121]

    iex> Zeam.toAddressInLittleEndian(<<255, 255, 255>>)
    [-1]

    iex> Zeam.toAddressInLittleEndian(<<254, 255, 255>>)
    [-2]
  """
  @spec toAddressInLittleEndian(binary) :: list
  def toAddressInLittleEndian(binary) do
    toAddress(&Zeam.concatLittleEndian/1, binary)
  end

  @doc """
  This reads binary (a sequence of bytes) and generates a list of integers that each value is regarded as a 24 bits (3 bytes) in big endian.

  ## Parameter

  - binary: is a binary to read

  ## Examples

    iex> Zeam.toAddressInBigEndian(<<0, 1, 2, 3>>)
    [258, 66051]

    iex> Zeam.toAddressInBigEndian(<<255, 255, 255>>)
    [-1]

    iex> Zeam.toAddressInBigEndian(<<255, 255, 254>>)
    [-2]
  """
  @spec toAddressInBigEndian(binary) :: list
  def toAddressInBigEndian(binary) do
    toAddress(&Zeam.concatBigEndian/1, binary)
  end

  @doc """
  This provides Template Method of toAddress{Little/Big}Endian/1.

  ## Parameter

  - function: is one of concat{Little/Big}Endian/1.
  - binary: is a binary to read.

  ## Examples

  	iex> Zeam.toAddress(&Zeam.concatLittleEndian/1, <<0, 1, 2, 3>>)
  	[131328, 197121]

  	iex> Zeam.toAddress(&Zeam.concatBigEndian/1, <<0, 1, 2, 3>>)
  	[258, 66051]
  """
  @spec toAddress(function, binary) :: list
  def toAddress(function, binary) when is_function(function, 1) do
  	for y <- (for x <- (binary |> bin2list |> bundle3Values), do: function.(x)), do: (if y < ((1 <<< 23) -1) do y else (y - (1 <<< 24)) end)
  end

  @doc """
  This returns list of absolute addresses.

  ## Parameter

  - function: is one of concat{Little/Big}Endian/1.
  - binary: is a binary to read.

  ## Examples

    iex> Zeam.toAbsoluteAddress(&Zeam.concatLittleEndian/1, <<0, 1, 2, 3>>)
    [131328, 197122]

    iex> Zeam.toAbsoluteAddress(&Zeam.concatBigEndian/1, <<0, 1, 2, 3>>)
    [258, 66052]
  """
  @spec toAbsoluteAddress(function, binary) :: list
  def toAbsoluteAddress(function, binary) when is_function(function, 1) do
    for x <- Enum.with_index(toAddress(function, binary)), do: elem(x, 0) + elem(x, 1)
  end

  @doc """
  This returns list of absolute addresses in little endian.

  ## Parameter

  - binary: is a binary to read.

  ## Examples

    iex> Zeam.toAbsoluteAddressInLittleEndian(<<0, 1, 2, 3>>)
    [131328, 197122]
  """
  @spec toAbsoluteAddressInLittleEndian(binary) :: list
  def toAbsoluteAddressInLittleEndian(binary) do
  	toAbsoluteAddress(&Zeam.concatLittleEndian/1, binary)
  end

  @doc """
  This returns list of absolute addresses in big endian.

  ## Parameter

  - binary: is a binary to read.

  ## Examples

    iex> Zeam.toAbsoluteAddressInBigEndian(<<0, 1, 2, 3>>)
    [258, 66052]
  """
  @spec toAbsoluteAddressInBigEndian(binary) :: list
  def toAbsoluteAddressInBigEndian(binary) do
  	toAbsoluteAddress(&Zeam.concatBigEndian/1, binary)
  end

  @doc """
  This returns a list of tupples of absolute addresses of the origin and the target.

  ## Parameter

  - function: is one of concat{Little/Big}Endian/1.
  - binary: is a binary to read.

  ## Examples

    iex> Zeam.toAddressOfOriginAndTarget(&Zeam.concatLittleEndian/1, <<0, 0, 0>>)
    [{0, 0}]

    iex> Zeam.toAddressOfOriginAndTarget(&Zeam.concatLittleEndian/1, <<1, 0, 0, 0>>)
    [{0, 1}, {1, 1}]

    iex> Zeam.toAddressOfOriginAndTarget(&Zeam.concatBigEndian/1, <<0, 0, 0>>)
    [{0, 0}]

    iex> Zeam.toAddressOfOriginAndTarget(&Zeam.concatBigEndian/1, <<0, 0, 1, 0>>)
    [{0, 1}, {1, 257}]
  """
  @spec toAddressOfOriginAndTarget(function, binary) :: list
  def toAddressOfOriginAndTarget(function, binary) when is_function(function, 1) do
	for x <- toAbsoluteAddress(function, binary) |> Enum.with_index, do: {elem(x, 1), elem(x, 0)}
  end

  @doc """
  This returns a list of tupples of absolute addresses in little endian of the origin and the target.

  ## Parameter

  - binary: is a binary to read.

  ## Examples

    iex> Zeam.toAddressInLittleEndianOfOriginAndTarget(<<0, 0, 0>>)
    [{0, 0}]

    iex> Zeam.toAddressInLittleEndianOfOriginAndTarget(<<1, 0, 0, 0>>)
    [{0, 1}, {1, 1}]
  """
  @spec toAddressInLittleEndianOfOriginAndTarget(binary) :: list
  def toAddressInLittleEndianOfOriginAndTarget(binary) do
  	toAddressOfOriginAndTarget(&Zeam.concatLittleEndian/1, binary)
  end

  @doc """
  This returns a list of tupples of absolute addresses in big endian of the origin and the target.

  ## Parameter

  - binary: is a binary to read.

  ## Examples

    iex> Zeam.toAddressInBigEndianOfOriginAndTarget(<<0, 0, 0>>)
    [{0, 0}]

    iex> Zeam.toAddressInBigEndianOfOriginAndTarget(<<0, 0, 1, 0>>)
    [{0, 1}, {1, 257}]
  """
  @spec toAddressInBigEndianOfOriginAndTarget(binary) :: list
  def toAddressInBigEndianOfOriginAndTarget(binary) do
  	toAddressOfOriginAndTarget(&Zeam.concatBigEndian/1, binary)
  end

  @doc """
  This returns a sorted list of tupples of absolute addresses of the origin and the target in order of the target address.

  ## Parameter

  - function: is one of concat{Little/Big}Endian/1.
  - binary: is a binary to read.

  ## Examples

  	iex> Zeam.toSortedListOfAddressOfOriginAndTarget(&Zeam.concatLittleEndian/1, <<0, 0, 0>>)
  	[{0, 0}]

  	iex> Zeam.toSortedListOfAddressOfOriginAndTarget(&Zeam.concatLittleEndian/1, <<1, 0, 0, 0>>)
  	[{1, 1}, {0, 1}]

  	iex> Zeam.toSortedListOfAddressOfOriginAndTarget(&Zeam.concatBigEndian/1, <<0, 0, 0>>)
  	[{0, 0}]

  	iex> Zeam.toSortedListOfAddressOfOriginAndTarget(&Zeam.concatBigEndian/1, <<0, 0, 1, 0>>)
  	[{0, 1}, {1, 257}]
  """
  @spec toSortedListOfAddressOfOriginAndTarget(function, binary) :: list
  def toSortedListOfAddressOfOriginAndTarget(function, binary) when is_function(function, 1) do
  	Enum.sort(toAddressOfOriginAndTarget(function, binary), fn(a, b) -> elem(a, 1) < elem(b, 1) end)
  end

  @doc """
  This returns a sorted list of tupples of absolute addresses in little endian of the origin and the target in order of the target address.

  ## Parameter

  - binary: is a binary to read.

  ## Examples

  	iex> Zeam.toSortedListOfAddressInLittleEndianOfOriginAndTarget(<<0, 0, 0>>)
  	[{0, 0}]

  	iex> Zeam.toSortedListOfAddressInLittleEndianOfOriginAndTarget(<<1, 0, 0, 0>>)
  	[{1, 1}, {0, 1}]
  """
  @spec toSortedListOfAddressInLittleEndianOfOriginAndTarget(binary) :: list
  def toSortedListOfAddressInLittleEndianOfOriginAndTarget(binary) do
  	toSortedListOfAddressOfOriginAndTarget(&Zeam.concatLittleEndian/1, binary)
  end

  @doc """
  This returns a sorted list of tupples of absolute addresses in big endian of the origin and the target in order of the target address.

  ## Parameter

  - binary: is a binary to read.

  ## Examples

  	iex> Zeam.toSortedListOfAddressInBigEndianOfOriginAndTarget(<<0, 0, 0>>)
  	[{0, 0}]

  	iex> Zeam.toSortedListOfAddressInBigEndianOfOriginAndTarget(<<0, 0, 1, 0>>)
  	[{0, 1}, {1, 257}]
  """
  @spec toSortedListOfAddressInBigEndianOfOriginAndTarget(binary) :: list
  def toSortedListOfAddressInBigEndianOfOriginAndTarget(binary) do
  	toSortedListOfAddressOfOriginAndTarget(&Zeam.concatBigEndian/1, binary)
  end

  @doc """
  This calls a function with a path, and puts to IO.

  ## Parameter

  - function: is a function that receives the path
  - path: is data or a binary file path

  """
  @spec put(function, Path.t()) :: String.t()
  def put(function, path) when is_function(function, 1) do
    IO.puts openAndCall(function, path)
  end

  @doc """
  This opens the file of a path and calls a function.

  ## Parameter

  - function: is a function that receives the path
  - path: is data or a binary file path to dump.
  """
  @spec openAndCall(function, Path.t()) :: String.t()
  def openAndCall(function, path) when is_function(function, 1) do
    {:ok, file} = File.open path, [:read]
    readFile(function, file)
  end

  @doc """
  This dumps binary files to String.

  ## Parameter

  - function: is a function that receives the path
  - file: is data or a binary file path to dump.

  """
  @spec readFile(function, File.t()) :: String.t()
  def readFile(function, file) when is_function(function, 1) do
    case IO.binread(file, :all) do
      {:error, reason} -> {:error, reason} 
      :eof -> ""
      "" -> ""
      data -> "#{function.(data)}\n#{readFile(function, file)}"
    end
  end

  @doc """
  This prints a tuple of addresses of the origin and the target

  ## Parameter

  - x: is a tuple including addresses of the origin and the target.

  ## Examples

  iex> Zeam.printElem({0, 0})
  "{0, 0}"

  iex> Zeam.printElem({0, -1})
  ""

  """
  @spec printElem(tuple) :: String.t()
  def printElem(x) do
  	if elem(x, 1) < 0 do
  	  ""
  	else
  	  "{#{Integer.to_string(elem(x, 0), 16)}, #{Integer.to_string(elem(x, 1), 16)}}"
  	end
  end

  @doc """
  This calls a function with a binary, obtains a list of tuples, and prints it.

  ## Parameter

  - function: is a function to call with a binary.
  - binary: is a binary to be converted by the function.
  """
  @spec printTupleList(function, binary) :: String.t()
  def printTupleList(function, binary) when is_function(function, 1) do
  	for x <- function.(binary), do: printElem(x)
  end

  @doc """
  This prints a sorted list of addresses in little endian of the origin and target from a binary.

  ## Parameter

  - binary: is a binary to print the list.

  ## Examples

  iex> Zeam.printSortedListInLittleEndian(<<0, 0, 0, 0>>)
  ["{0, 0}", "{1, 1}"]

  iex> Zeam.printSortedListInLittleEndian(<<1, 0, 0, 0>>)
  ["{1, 1}", "{0, 1}"]

  """
  @spec printSortedListInLittleEndian(binary) :: String.t()
  def printSortedListInLittleEndian(binary) do
  	printTupleList(&Zeam.toSortedListOfAddressInLittleEndianOfOriginAndTarget/1, binary)
  end

  @doc """
  This prints a sorted list of addresses in big endian of the origin and target from a binary.

  ## Parameter

  - binary: is a binary to print the list.

  ## Examples

  iex> Zeam.printSortedListInBigEndian(<<0, 0, 0, 0>>)
  ["{0, 0}", "{1, 1}"]

  iex> Zeam.printSortedListInBigEndian(<<0, 0, 1, 0>>)
  ["{0, 1}", "{1, 101}"]
  """
  @spec printSortedListInBigEndian(binary) :: String.t()
  def printSortedListInBigEndian(binary) do
  	printTupleList(&Zeam.toSortedListOfAddressInBigEndianOfOriginAndTarget/1, binary)
  end

  @doc """
  This puts a sorted list of addresses in little endian of the origin and the target from the binary read from the file of a path.

  ## Parameter

  - path: is data or a binary file path to put.

  ## Examples

  iex> Zeam.putAddressInLittleEndian("./test/sample")
  "{0, 434241}{1, 444343}{2, 454445}{3, 464547}{4, 474649}{5, 48474B}{6, 49484D}{7, 4A494F}{8, 4B4A51}{9, 4C4B53}{A, 4D4C55}{B, 4E4D57}\n"

  """
  @spec putAddressInLittleEndian(Path.t()) :: String.t()
  def putAddressInLittleEndian(path) do
  	openAndCall(&Zeam.printSortedListInLittleEndian/1, path)
  end

  @doc """
  This puts a sorted list of addresses in big endian of the origin and the target from the binary read from the file of a path.

  ## Parameter

  - path: is data or a binary file path to put.

  ## Examples

  iex> Zeam.putAddressInBigEndian("./test/sample")
  "{0, 414243}{1, 424345}{2, 434447}{3, 444549}{4, 45464B}{5, 46474D}{6, 47484F}{7, 484951}{8, 494A53}{9, 4A4B55}{A, 4B4C57}{B, 4C4D59}\n"

  """
  @spec putAddressInBigEndian(Path.t()) :: String.t()
  def putAddressInBigEndian(path) do
  	openAndCall(&Zeam.printSortedListInBigEndian/1, path)
  end

  @doc """
  This dumps binary files to stdard output.

  ## Parameter

  - path: is data or a binary file path to dump.

  """
  @spec dump(Path.t()) :: String.t()
  def dump(path) do
    put(&Zeam.dump_d/1, path)
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
