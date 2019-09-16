if Code.ensure_compiled?(Ecto.Type) do
  defmodule Money.Ecto.Amount.Type do
    @moduledoc """
    Provides a type for Ecto to store a amount.
    The underlying data type should be an integer.

    ## Migration Example

        create table(:my_table) do
          add :amount, :integer
        end

    ## Schema Example

        schema "my_table" do
          field :amount, Money.Ecto.Amount.Type
        end
    """

    if macro_exported?(Ecto.Type, :__using__, 1) do
      use Ecto.Type
    else
      @behaviour Ecto.Type
    end

    @spec type :: :integer
    def type, do: :integer

    @spec cast(String.t() | integer()) :: {:ok, Money.t()}
    def cast(val)

    def cast(str) when is_binary(str) do
      case Money.parse(str) do
        {:ok, money} -> {:ok, money.amount}
        _ -> :error
      end
    end

    def cast(int) when is_integer(int), do: {:ok, Money.new(int).amount}

    def cast(%Money{currency: currency, amount: amount}) do
      case same_as_default_currency?(currency) do
        true -> {:ok, amount}
        _ -> :error
      end
    end

    def cast(%{"amount" => amount, "currency" => currency}) do
      case same_as_default_currency?(currency) do
        true -> {:ok, amount}
        _ -> :error
      end
    end

    def cast(%{"amount" => amount}), do: {:ok, amount}

    def cast(%{amount: amount, currency: currency}) do
      case same_as_default_currency?(currency) do
        true -> {:ok, amount}
        _ -> :error
      end
    end

    def cast(%{amount: amount}), do: {:ok, amount}

    def cast(_), do: :error

    @spec load(integer()) :: {:ok, Money.t()}
    def load(int) when is_integer(int), do: {:ok, Money.new(int)}

    @spec dump(integer() | Money.t()) :: {:ok, integer()}
    def dump(int) when is_integer(int), do: {:ok, int}
    def dump(%Money{} = m), do: {:ok, m.amount}
    def dump(_), do: :error

    defp same_as_default_currency?(currency) do
      default_currency_string = Application.get_env(:money, :default_currency) |> to_string |> String.downcase()
      currency_string = currency |> to_string |> String.downcase()
      default_currency_string == currency_string
    end
  end
end
