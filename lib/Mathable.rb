module Mathable
  def average(numerator, denominator)
    ((numerator.to_f / denominator)*100).round(2)
  end

  def small_average(numerator, denominator)
    (numerator.to_f / denominator).round(2)
  end
end
