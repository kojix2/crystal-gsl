require "./matrix.cr"
require "./vector.cr"

module GSL
  alias Function = (Float64 -> Float64)
  alias FunctionFDF = (Float64 -> Tuple(Float64, Float64))

  # wraps user supplied function (can be closured) to the `LibGSL::Gsl_Function` structure. Used internally in high-level wrappers.
  #
  #
  # Note that if you use it directly and pass resulting function to some C code, you have to keep reference somewhere so it won't be garbage collected.
  # Usually, it's not a problem because reference will remain on stack. So
  # ```
  # ...
  # function = GSL.wrap_function(f)
  # LibGSL.gsl_root_fsolver_set(raw, pointerof(function), x_lower, x_upper)
  # max_iter.times do
  #   LibGSL.gsl_root_fsolver_iterate(raw)
  #   ...
  # end
  # ```
  # won't be a problem (reference is saved in local variable `function`).
  #
  # But
  # ```
  # def init_solver(f)
  #   ...
  #   function = GSL.wrap_function(f)
  #   LibGSL.gsl_root_fsolver_set(raw, pointerof(function), x_lower, x_upper)
  #   return raw
  # end
  # ```
  # will cause a problem - local variable `function` will be GC'd.
  def self.wrap_function(function : Function)
    result = uninitialized LibGSL::Gsl_function
    if function.closure?
      box = Box.box(function)
      # (LibC::Double, Void* -> LibC::Double)
      result.function = ->(x : Float64, data : Void*) do
        Box(Function).unbox(data).call(x)
      end
      result.params = box # no need to keep reference to `box` as `result` holds it.
    else
      result.params = function.pointer
      result.function = ->(x : Float64, data : Void*) do
        Function.new(data, Pointer(Void).null).call(x)
      end
    end
    result
  end

  # wraps user supplied function (can be closured) to the `LibGSL::Gsl_Function` structure. Used internally in high-level wrappers.
  def self.wrap_function(&function : Function)
    wrap_function(function)
  end

  # wraps user supplied function (can be closured) to the `LibGSL::Gsl_function_fdf` structure. Used internally in high-level wrappers.
  def self.wrap_function(function : FunctionFDF)
    result = uninitialized LibGSL::Gsl_function_fdf
    if function.closure?
      box = Box.box(function)
      # (LibC::Double, Void*, LibC::Double*, LibC::Double* -> Void)
      result.f = ->(x : Float64, data : Void*) do
        f, _ = Box(FunctionFDF).unbox(data).call(x)
        f
      end
      result.df = ->(x : Float64, data : Void*) do
        _, df = Box(FunctionFDF).unbox(data).call(x)
        df
      end
      result.fdf = ->(x : Float64, data : Void*, f : Float64*, df : Float64*) do
        f.value, df.value = Box(FunctionFDF).unbox(data).call(x)
      end
      result.params = box # no need to keep reference to `box` as `result` holds it.
    else
      result.params = function.pointer
      result.f = ->(x : Float64, data : Void*) do
        f, _ = FunctionFDF.new(data, Pointer(Void).null).call(x)
        f
      end
      result.df = ->(x : Float64, data : Void*) do
        _, df = FunctionFDF.new(data, Pointer(Void).null).call(x)
        df
      end
      result.fdf = ->(x : Float64, data : Void*, f : Float64*, df : Float64*) do
        f.value, df.value = FunctionFDF.new(data, Pointer(Void).null).call(x)
      end
    end
    result
  end

  # wraps user supplied function (can be closured) to the `LibGSL::Gsl_function_fdf` structure. Used internally in high-level wrappers.
  def self.wrap_function(&function : FunctionFDF)
    wrap_function(function)
  end

  alias FunctionVS = (Slice(Float64) -> Float64)

  # wraps user supplied function (can be closured) to the `LibGSL::Gsl_monte_function` structure. Used internally in high-level wrappers.
  def self.wrap_function_monte(function : FunctionVS, dim)
    result = uninitialized LibGSL::Gsl_monte_function
    result.dim = dim
    if function.closure?
      box = Box.box(function)
      result.f = ->(x : Float64*, dim : UInt64, data : Void*) do
        Box(FunctionVS).unbox(data).call(x.to_slice(dim))
      end
      result.params = box # no need to keep reference to `box` as `result` holds it.
    else
      result.params = function.pointer
      result.f = ->(x : Float64*, dim : UInt64, data : Void*) do
        FunctionVS.new(data, Pointer(Void).null).call(x.to_slice(dim))
      end
    end
    result
  end

  # wraps user supplied function (can be closured) to the `LibGSL::Gsl_monte_function` structure. Used internally in high-level wrappers.
  def self.wrap_function_monte(dim, &function : FunctionVS)
    wrap_function_monte(function, dim)
  end

  alias MultiRootFunction = (Vector, Vector -> Void)
  alias MultiRootFunctionFDF = (Vector, Vector?, DenseMatrix? -> Void)

  # wraps user supplied function (can be closured) to the `LibGSL::Gsl_multiroot_function` structure. Used internally in high-level wrappers.
  def self.wrap_function(function : MultiRootFunction)
    result = uninitialized LibGSL::Gsl_multiroot_function
    if function.closure?
      box = Box.box(function)
      # (LibGSL::Gsl_vector*, Void*, LibGSL::Gsl_vector* -> Int)
      result.f = ->(x : LibGSL::Gsl_vector*, data : Void*, f : LibGSL::Gsl_vector*) do
        Box(MultiRootFunction).unbox(data).call(x.unsafe_as(Vector), f.unsafe_as(Vector))
        LibGSL::Code::GSL_SUCCESS
      end
      result.params = box # no need to keep reference to `box` as `result` holds it.
    else
      result.params = function.pointer
      result.f = ->(x : LibGSL::Gsl_vector*, data : Void*, f : LibGSL::Gsl_vector*) do
        MultiRootFunction.new(data, Pointer(Void).null).call(x.unsafe_as(Vector), f.unsafe_as(Vector))
        LibGSL::Code::GSL_SUCCESS
      end
    end
    result
  end

  # wraps user supplied function (can be closured) to the `LibGSL::Gsl_multiroot_function` structure. Used internally in high-level wrappers.
  def self.wrap_function(&function : MultiRootFunction)
    wrap_function(function)
  end

  class DenseMatrix
    # :nodoc:
    def initialize(*, hack_null : Bool)
      @pointer = Pointer(Gsl_matrix).null
    end

    # :nodoc:
    def hack_set_ptr(ptr)
      @pointer = Pointer(Gsl_matrix)
    end
  end

  # wraps user supplied function (can be closured) to the `LibGSL::Gsl_multiroot_function_fdf` structure. Used internally in high-level wrappers.
  def self.wrap_function(function : MultiRootFunctionFDF)
    result = uninitialized LibGSL::Gsl_multiroot_function_fdf

    box = Box.box({function, DenseMatrix.new(hack_null: true)})
    result.f = ->(x : LibGSL::Gsl_vector*, data : Void*, f : LibGSL::Gsl_vector*) do
      function, _ = Box(Tuple(MultiRootFunctionFDF, DenseMatrix)).unbox(data)
      function.call(x.unsafe_as(Vector), f.unsafe_as(Vector), nil)
      LibGSL::Code::GSL_SUCCESS
    end
    result.df = ->(x : LibGSL::Gsl_vector*, data : Void*, m : LibGSL::Gsl_matrix*) do
      function, matrix = Box(Tuple(MultiRootFunctionFDF, DenseMatrix)).unbox(data)
      matrix.hack_set_ptr m
      function.call(x.unsafe_as(Vector), nil, matrix)
      LibGSL::Code::GSL_SUCCESS
    end
    result.fdf = ->(x : LibGSL::Gsl_vector*, data : Void*, f : LibGSL::Gsl_vector*, m : LibGSL::Gsl_matrix*) do
      function, matrix = Box(Tuple(MultiRootFunctionFDF, DenseMatrix)).unbox(data)
      matrix.hack_set_ptr m
      function.call(x.unsafe_as(Vector), f.unsafe_as(Vector), matrix)
    end
    result.params = box # no need to keep reference to `box` as `result` holds it.
    result
  end

  # wraps user supplied function (can be closured) to the `LibGSL::Gsl_multiroot_function_fdf` structure. Used internally in high-level wrappers.
  def self.wrap_function(&function : MultiRootFunctionFDF)
    wrap_function(function)
  end
end
