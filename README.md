# Pickle

This project was forked from [Cabbage](https://github.com/cabbage-ex/cabbage) to try and do very little maintenaince for internal use.

<img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpb_92f0kKiUeokWg5SCp79eazxY7ztzPVSTfCaDhApyHUeBkBJ0uxTXT2PPavy6nnRLk&usqp=CAU" width="240px" height="180px"></img>
##### (Looking contribution for a better icon!)

A simple addon on top of [ExUnit](https://hexdocs.pm/ex_unit/ExUnit.html) which provides compile time translation of `.feature` files to exunit tests. Big thanks to [@meadsteve](https://github.com/meadsteve) and the [White Bread](https://github.com/meadsteve/white-bread) project for a huge head start on this project.

## Installation

The package can be installed as:

  1. Add `pickle` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:pickle, "~> 0.5.2", only: :test, github: "Mathison-Inc/pickle", ref: "v0.5.2"}]
end
```

## Example Usage

By default, feature files are expected inside `test/features`. This can be configured within your application with the following:

```elixir
config :pickle, features: "some/other/path/from/your/project/root"
```

Inside `test/features/coffee.feature` you might have something like:

```gherkin
Feature: Serve coffee
  Coffee should not be served until paid for
  Coffee should not be served until the button has been pressed
  If there is no coffee left then money should be refunded

  Scenario: Buy last coffee
    Given there are 1 coffees left in the machine
    And I have deposited £1
    When I press the coffee button
    Then I should be served a coffee
```

To translate this to a simple exunit test, all you need to do is provide the translation of lines to steps in the test. Inside `test/features/coffee_test.exs` (or anywhere you like really).

```elixir
defmodule MyApp.Features.CoffeeTest do
  # Options, other than file:, are passed directly to `ExUnit`
  use Pickle.Feature, async: false, file: "coffee.feature"

  # `setup_all/1` provides a callback for doing something before the entire suite runs
  # As below, `setup/1` provides means of doing something prior to each scenario
  setup do
    on_exit fn -> # Do something when the scenario is done
      IO.puts "Scenario completed, cleanup stuff"
    end
    %{my_starting: :state, user: %User{}} # Return some beginning state
  end

  # All `defgiven/4`, `defwhen/4` and `defthen/4` takes a regex, matched data, state and lastly a block
  defgiven ~r/^there (is|are) (?<number>\d+) coffee(s) left in the machine$/, %{number: number}, %{user: user} do
    # `{:ok, state}` gets returned from each callback which updates the state or
    # leaves the state unchanged when something else is returned
    {:ok, %{machine: Machine.put_coffee(Machine.new, number)}}
  end

  defgiven ~r/^I have deposited £(?<number>\d+)$/, %{number: number}, %{user: user, machine: machine} do
    {:ok, %{machine: Machine.deposit(machine, user, number)}} # State is automatically merged so this won't erase `user`
  end

  # With no matches, the map is empty. Since state is unchanged, its not necessary to return it
  defwhen ~r/^I press the coffee button$/, _, state do
    Machine.press_coffee(state.machine) # instead would be some `hound` or `wallaby` dsl
  end

  # Since state is unchanged, its not necessary to return it
  defthen ~r/^I should be served a coffee$/, _, state do
    assert %Coffee{} = Machine.take_drink(state.machine) # Make your `assert`ions in `defthen/4`s
  end
end
```

The resulting compiled test will be logically equivalent to:

```elixir
defmodule MyApp.Features.CoffeeTest do
  use ExUnit.Case, async: false

  setup do
    on_exit fn ->
      IO.puts "Scenario completed, cleanup stuff"
    end
    {:ok, %{my_starting: :state, user: %User{}}}
  end

  # Each scenario would generate a single test case
  @tag :integration
  test "Buy last coffee", %{my_starting: :state, user: user} do
    # From the given
    state = %{user: user, machine: Machine.put_coffee(Machine.new, number)}
    # From the and
    state = Map.put(state, :machine, Machine.deposit(machine, user, number))
    # From the when
    Machine.press_coffee(state.machine)
    # From the then
    assert %Coffee{} = Machine.take_drink(state.machine)
  end
end
```

This provides the best of both worlds. Feature files for non-technical users, and an actual test file written in Elixir for developers that have to maintain them.

### Tables & Doc Strings

Using tables and Doc Strings can be done easily, they are provided through the variables under the names `:table` and `:doc_string`. An example can be seen in [test/data_tables_test.exs](test/data_tables_test.exs) and [test/features/data_tables.feature](test/features/data_tables.feature).

### Running specific tests

Typically to run an ExUnit test you would do something like `mix test test/some_test.exs:12` and elixir will automatically load  `test/some_test.exs` for you, but only run the test on line `12`. Since the feature files are being translated into ExUnit at compile time, you'll have to specify the `.exs` file and not the `.feature` file to run. The line numbers are printed out as each test runs (at the `:info` level, so you may need to increase your logger config if you dont see anything). An example is like as follows:

    # Runs scenario of test/features/coffee.feature on line 13
    mix test test/feature_test.exs:13

# Developing

## Using Docker Compose

A `docker-compose.yml` is provided for running the tests in containers.

```shell
$ docker-compose up
```

To wipe all `_build` and `deps` you can run:
```shell
$ docker-compose down -v
```

If you want to interactive, using standard `mix` commands, such as updating dependencies:

```shell
$ docker-compose run --rm test deps.update --all
```

Or, if you want to run a single test, that can be accomplished with:

```shell
$ docker-compose run --rm pickle test test/feature_test.exs
```

# Roadmap

- [x] Scenarios
- [x] Scenario Outlines
- [x] ExUnit Case Templates
- [x] Data tables
- [x] Executing specific tests
- [x] Tags implementation
- [x] Background steps
- [x] Rules
