require "../../base/*"
require "./find_bracket"

private GSL_SQRT_DBL_EPSILON = 1.4901161193847656e-08

# This module implements [One Dimensional Minimization](https://www.gnu.org/software/gsl/doc/html/min.html)
#
# Usage example:
# ```
# xm, fm = GSL::Min.find_min(0, 6, 1e-6) do |x|
#   Math.cos(x)
# end
# xm.should be_close Math::PI, 1e-6
# ```
#
module GSL::Min
  # Minimization algorithm
  enum Type
    # The golden section algorithm is the simplest method of bracketing the minimum of a function. It is the slowest algorithm provided by the library, with linear convergence.
    GoldenSection
    # The Brent minimization algorithm combines a parabolic interpolation with the golden section algorithm. This produces a fast algorithm which is still robust.
    Brent
    # This is a variant of Brent’s algorithm which uses the safeguarded step-length algorithm of Gill and Murray.
    QuadGolden

    def to_unsafe
      case self
      in .golden_section?
        LibGSL.gsl_min_fminimizer_goldensection
      in .brent?
        LibGSL.gsl_min_fminimizer_brent
      in .quad_golden?
        LibGSL.gsl_min_fminimizer_quad_golden
      end
    end

    def to_s
      String.new(LibGSL.gsl_min_fminimizer_name(to_unsafe))
    end
  end

  # High-level interface to minimizer. Finds minimum of function f between `x_lower` and `x_upper`.
  #
  # - `eps` - required absolute precision
  # - `algorithm` - minimization algorithm to be used. By default either `Brent` (if `guess` is present) or `QuadGolden` (othrwise) is used.
  # - `max_iter` - maximum number of function evaluations, used to stop iterating when solution doesn't converge
  # - `guess` - initial guess of a root value that can speed up search. If present, f(guess) < f(x_lower) and f(guess) < f(x_upper) should hold.
  #
  # returns nil if number of iterations = max_iter is exceeded
  #
  # returns {x_min, f_min} tuple if precision = eps achieved
  def self.find_min?(x_lower : Float64, x_upper : Float64, eps : Float64 = 1e-9, *,
                     algorithm : GSL::Min::Type? = nil,
                     max_iter = 1000, guess = nil, &f : GSL::Function)
    algorithm = guess ? GSL::Min::Type::Brent : GSL::Min::Type::QuadGolden
    raw = LibGSL.gsl_min_fminimizer_alloc(algorithm.to_unsafe)
    begin
      function = GSL.wrap_function(f)
      if guess
        LibGSL.gsl_min_fminimizer_set(raw, pointerof(function), guess, x_lower, x_upper)
      else
        f_lower = f.call(x_lower)
        f_upper = f.call(x_upper)
        x_min = x_lower
        f_min = f_lower
        # LibGSL.gsl_min_find_bracket(pointerof(function), pointerof(x_min), pointerof(f_min), pointerof(x_lower), pointerof(f_lower), pointerof(x_upper), pointerof(f_upper), max_iter//2)
        result = GSL::Min.min_find_bracket(f, pointerof(x_min), pointerof(f_min), pointerof(x_lower), pointerof(f_lower), pointerof(x_upper), pointerof(f_upper), max_iter//2)
        LibGSL.gsl_min_fminimizer_set_with_values(raw, pointerof(function),
          x_min, f_min, x_lower, f_lower, x_upper, f_upper)
      end
      ok = false
      max_iter.times do
        LibGSL.gsl_min_fminimizer_iterate(raw)
        if LibGSL::Code.new(LibGSL.gsl_min_test_interval(x_lower, x_upper, eps, 0.0)) == LibGSL::Code::GSL_SUCCESS
          ok = true
          break
        end
      end
      ok = ok || (raw.value.f_upper - raw.value.f_minimum < GSL_SQRT_DBL_EPSILON)
      result = ok ? {raw.value.x_minimum, raw.value.f_minimum} : nil
      result
    ensure
      LibGSL.gsl_min_fminimizer_free(raw)
    end
  end

  # High-level interface to minimizer. Finds minimum of function f between `x_lower` and `x_upper`.
  #
  # - `eps` - required absolute precision
  # - `algorithm` - minimization algorithm to be used
  # - `max_iter` - maximum number of function evaluations, used to stop iterating when solution doesn't converge
  # - `guess` - initial guess of a root value that can speed up search. If present, f(guess) < f(x_lower) and f(guess) < f(x_upper) should hold.
  #
  # raises IterationsLimitExceeded if number of iterations = max_iter is exceeded
  #
  # returns {x_min, f_min} tuple if precision = eps achieved
  def self.find_min(x_lower : Float64, x_upper : Float64, eps : Float64,
                    algorithm : GSL::Min::Type? = nil,
                    max_iter = 1000, guess = nil, &f : GSL::Function)
    find_min?(x_lower, x_upper, eps, algorithm: algorithm, max_iter: max_iter, guess: guess, &f) || raise IterationsLimitExceeded.new("find_min didn't converge")
  end
end
