require "./spec_helper"

describe GSL do
  describe "functions defined with def_function" do
    it "must return the correct value" do
      x = GSL.lngamma(0.1)
      x.should eq 2.2527126517342047
    end
  end

  describe "functions defined with def_function_with_mode" do
    it "must return the correct value" do
      x = GSL.airy_Ai(-500, precision: :approx)
      x.should be_close 0.0725901201040411396, 1e-7
      x = GSL.airy_Ai(-5)
      x.should be_close 0.3507610090241142, 1e-14
    end
  end

  describe "functions defined with def_function_with_args" do
    it "must return the correct value" do
      x = GSL.airy_zero_Ai(2)
      x.should eq -4.087949444130970617
      x = GSL.bessel_Jn(5, 2.0)
      x.should be_close 0.007039629755871685484, 1e-14
    end
  end
end
