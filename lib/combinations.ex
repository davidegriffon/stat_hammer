defmodule Combinations do
  def of(n, _r) when not is_integer(n), do: raise(ArithmeticError)
  def of(_n, r) when not is_integer(r), do: raise(ArithmeticError)
  def of(n, r) when n < r do
    raise ArgumentError, message: "n >= r"
  end
  def of(n, n) do
    1
  end

  @doc """
  This function calculate the combinations for n things taken r at a time.
  This number is equals to:
    n! / ( (n - r)! * r! )
  """
  def of(n, r) do
    numerator = Factorial.of(n)
    denominator = Factorial.of(n - r) * Factorial.of(r)
    Fraction.new(numerator, denominator)
  end
end
