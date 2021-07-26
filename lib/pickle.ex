defmodule Pickle do
  @moduledoc """
  """
  def base_path(), do: Application.get_env(:pickle, :features, "test/features/")
  def global_tags(), do: Application.get_env(:pickle, :global_tags, []) |> List.wrap()
end
