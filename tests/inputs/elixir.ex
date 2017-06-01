# This is a test for the Elixir SLOC counter.

defmodule Test do
  @moduledoc """
  Test module
  """
  @notdoc :foo

  @doc ~S"""
  Foo
  """
  def foo do
    @notdoc
  end

  @doc ~c'''
  Bar
  '''
  def bar, do: :bar
end
