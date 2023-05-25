require "./spec_helper"

describe GSL do
  describe "One Dimensional Root Finding" do
    it "performs root bracketing using high-level interface" do
      result, xm = GSL::Roots.find_root(0, 3) do |x|
        Math.cos(x) - 0.5
      end
      result.success?.should be_true
      xm.should be_close(Math::PI / 3, 1e-9)
    end

    it "can find root with given precision" do
      _, xm = GSL::Roots.find_root(0, 3, 1e-3) do |x|
        Math.cos(x) - 0.5
      end
      xm.should be_close(Math::PI / 3, 1e-3)
    end

    it "can find root using given algorithm" do
      [GSL::Roots::TypeBracketing::Bisection, GSL::Roots::TypeBracketing::FalsePosition, GSL::Roots::TypeBracketing::BrentDekker].each do |algo|
        result, xm = GSL::Roots.find_root(0, 3, algorithm: algo) do |x|
          Math.cos(x) - 0.5
        end
        result.success?.should be_true
        xm.should be_close(Math::PI / 3, 1e-9)
      end
    end

    it "correctly process closured function" do
      a = 1
      b = 0
      c = -5
      _, xm = GSL::Roots.find_root(0, 5) do |x|
        (a*x + b)*x + c
      end
      xm.should be_close(Math.sqrt(5), 1e-9)
    end

    it "raises when bracketing isn't possible" do
      expect_raises(GSL::InternalException) do
        GSL::Roots.find_root(0, Math::PI*2) do |x|
          Math.cos(x) - 0.5
        end
      end
    end

    it "behaves correctly when function raises" do
      expect_raises(ArgumentError) do
        GSL::Roots.find_root(0, 3) do |x|
          raise ArgumentError.new("incorrect call")
        end
      end
    end

    it "can polish root from initial guess" do
      result, x = GSL::Roots.polish_root(5) do |x|
        {x*x - 5, 2*x}
      end
      result.success?.should be_true
      x.should be_close(Math.sqrt(5), 1e-9)
    end

    it "can polish root from initial guess inside a range" do
      result, root = GSL::Roots.polish_root(10, x_possible: (0.0..)) do |x|
        {x*x*x - 125, 3*x*x}
      end
      result.success?.should be_true
      root.should be_close 5, 1e-9
      result, root = GSL::Roots.polish_root(10, x_possible: (6.0..)) do |x|
        {x*x*x - 125, 3*x*x}
      end
      result.success?.should be_false
    end

    it "Secant only use derivation in initial point" do
      _, root = GSL::Roots.polish_root(10, algorithm: GSL::Roots::TypePolishing::Secant) do |x|
        {x*x*x - 125, 3.0*10*10}
      end
      root.should be_close 5, 1e-9
    end
  end
end
