defmodule Zeam do
  @moduledoc """
  Zeam is a module of ZEAM. ZEAM is ZACKY's Elixir Abstract Machine, which is aimed at being BEAM compatible.
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
end
