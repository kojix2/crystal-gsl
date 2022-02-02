module GSL::Integration
  # The QNG algorithm is a non-adaptive procedure which uses fixed Gauss-Kronrod-Patterson abscissae to sample the
  # integrand at a maximum of 87 points.
  # It is provided for fast integration of smooth functions
  # Integrates `function` from `a` to `b` with absolute precision `epsabs` OR relative precision `epsrel`.
  # If none of precisions given, it is assumed that `epsabs = 1e-9`.
  # Returns integration result, estimated error and number of evaluations.
  # Example: ```
  # f = ->(x : Float64) { Math.sin(x) }
  # result, eps, count = GSL::Integration.qng(f, 0.0, Math::PI/2)`
  # ```
  #
  def self.qng(function : Proc(Float64, Float64), a : Float64, b : Float64, *, epsabs : Float64 = 0.0, epsrel : Float64 = 0.0)
    f = GSL.wrap_function(function)
    if epsabs.zero? && epsrel.zero?
      epsabs = 1e-9
    end
    code = LibGSL::Code.new(LibGSL.gsl_integration_qng(pointerof(f), a, b, epsabs, epsrel, out result, out abserr, out neval))
    return result, abserr, neval
  end

  # Yielding version of `#qng`
  # Example: ```
  # result, eps, count = GSL::Integration.qng(0.0, Math::PI/2) { |x| Math.sin(x) }`
  # ```
  #
  def self.qng(a : Float64, b : Float64, *, epsabs : Float64 = 0.0, epsrel : Float64 = 0.0, &function : Proc(Float64, Float64))
    qng(function, a, b, epsabs: epsabs, epsrel: epsrel)
  end

  enum QAGKey
    GSL_INTEG_GAUSS15 = 1
    GSL_INTEG_GAUSS21 = 2
    GSL_INTEG_GAUSS31 = 3
    GSL_INTEG_GAUSS41 = 4
    GSL_INTEG_GAUSS51 = 5
    GSL_INTEG_GAUSS61 = 6
  end

  @@workspace = Pointer(LibGSL::Gsl_integration_workspace).null
  @@workspace_size = 0

  def self.qag(function : Proc(Float64, Float64), a : Float64, b : Float64, *, epsabs : Float64 = 0.0, epsrel : Float64 = 0.0, limit = 1000, key : QAGKey = QAGKey::GSL_INTEG_GAUSS61)
    if limit > @@workspace_size
      LibGSL.gsl_integration_workspace_free(@@workspace) unless @@workspace.null?
      @@workspace = LibGSL.gsl_integration_workspace_alloc(limit)
      @@workspace_size = limit
    end
    f = GSL.wrap_function(function)
    if epsabs.zero? && epsrel.zero?
      epsabs = 1e-9
    end
    code = LibGSL::Code.new(LibGSL.gsl_integration_qag(pointerof(f), a, b, epsabs, epsrel, limit, key.to_i, @@workspace, out result, out abserr))
    return result, abserr
  end
end
