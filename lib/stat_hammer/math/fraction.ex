defmodule StatHammer.Math.Fraction do
  alias StatHammer.Math.Fraction

  @type t :: %__MODULE__{
    numerator: integer(),
    denominator: integer(),
  }
  @enforce_keys [:numerator, :denominator]
  defstruct [:numerator, :denominator]

  def new(x), do: new(x, 1)

  def new(x, _y) when is_float(x), do: raise(ArithmeticError)
  def new(_x, y) when is_float(y), do: raise(ArithmeticError)
  def new(_n, 0), do: raise(ArithmeticError)

  def new(numerator, denominator) do
    gcd = gcd(numerator, denominator)
    n = div(numerator, gcd)
    d = div(denominator, gcd)
    sign = sign(n * d)
    %Fraction{numerator: sign * Kernel.abs(n), denominator: Kernel.abs(d)}
  end

  defp sign(x) when x < 0, do: -1
  defp sign(x) when x >= 0, do: 1

  def add(lhs = %Fraction{}, %Fraction{numerator: 0, denominator: _d}) do
    lhs
  end

  def add(lhs = %Fraction{}, rhs = %Fraction{}) do
    Fraction.new(
      lhs.numerator * rhs.denominator + rhs.numerator * lhs.denominator,
      lhs.denominator * rhs.denominator
    )
  end

  def add(lhs, rhs), do: add(Fraction.new(lhs), Fraction.new(rhs))

  def subtraction(lhs = %Fraction{}, rhs = %Fraction{}) do
    Fraction.new(
      lhs.numerator * rhs.denominator - rhs.numerator * lhs.denominator,
      lhs.denominator * rhs.denominator
    )
  end

  def division(lhs = %Fraction{}, rhs = %Fraction{}) do
    Fraction.multiply(lhs, reciprocal(rhs))
  end

  def division(lhs, rhs), do: division(Fraction.new(lhs), Fraction.new(rhs))

  def multiply(lhs = %Fraction{}, rhs = %Fraction{}) do
    Fraction.new(
      lhs.numerator * rhs.numerator,
      lhs.denominator * rhs.denominator
    )
  end

  def reciprocal(f = %Fraction{}), do: Fraction.new(f.denominator, f.numerator)

  defp gcd(x, 0), do: x
  defp gcd(x, y), do: gcd(y, rem(x, y))

  def pow(f = %Fraction{}, n) do
    Enum.reduce(
      List.duplicate(f, n),
      Fraction.new(1),
      fn lhs, rhs -> multiply(lhs, rhs) end
    )
  end

  @doc """
  The given function should compare two fractions,
  and return true if the first argument precedes or is in the same place as the second one.
  """
  def compare(a = %Fraction{}, b = %Fraction{}) do
    Fraction.subtraction(a, b).numerator < 0
  end
end
