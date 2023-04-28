require "./spec_helper"

ROWS = 5
COLS = 5
test_matrix = GSL::SparseMatrix.new ROWS, COLS

describe GSL::SparseMatrix do
  describe "#nrows" do
    it "should return the number of rows of a matrix" do
      test_matrix.nrows.should eq ROWS
    end
  end
  describe "#ncols" do
    it "should return the number of columns of a matrix" do
      test_matrix.ncols.should eq COLS
    end
  end
  describe "#shape" do
    it "should return the shape of a matrix" do
      test_matrix.shape.should eq({ROWS, COLS})
    end
  end
  describe "#[]" do
    it "should return a value of expected index" do
      test_matrix[0, 0].should eq 0.0
    end
    it "should return a vector of expected column" do
      test_matrix[:all, 0].should eq(GSL::Vector.new ROWS)
    end
    it "should return a vector of expected row" do
      test_matrix[0, :all].should eq(GSL::Vector.new COLS)
    end
    it "should return a matrix with the same dimensions" do
      temp = test_matrix.like
      temp.shape.should eq({5, 5})
    end
  end
  describe "#set_zero" do
    it "should set all the values in the sparse matrix to zero" do
      temp = GSL::SparseMatrix.new ROWS, COLS
      temp[0, 0] = 10
      temp.set_zero.should eq test_matrix
    end
  end
  describe "#*" do
    it "should return the scaling of two matrices" do
      temp = test_matrix.like
      temp[0, 0] = 7.0
      result = test_matrix.like
      result[0, 0] = 14.0
      (temp * 2.0).should eq result
    end
  end
  describe "#non_zero" do
    it "should count all non-zero entries" do
      temp = GSL::SparseMatrix.new ROWS, COLS
      temp[0, 0] = 10
      temp[1, 1] = 5.0
      temp.non_zero.should eq 2
    end
  end
  describe "#minmax" do
    it "should return the minimum and maximun value of the matrix" do
      temp = test_matrix.like
      temp[0, 0] = 1
      temp.minmax.should eq({0, 1})
    end
    it "should return 0 value for empty matrix" do
      temp = test_matrix.like
      temp.minmax.should eq({0, 0})
    end
  end

  describe ".new" do
    it "should create empty COO matrix" do
      sp = GSL::SparseMatrix.new 5, 5
      sp.type.should eq GSL::SparseMatrix::Type::COO
    end
    it "should create sparse matrix of given type" do
      sp = GSL::SparseMatrix.new 5, 5, :csr
      sp.type.should eq GSL::SparseMatrix::Type::CSR
    end

    it "should create copy of matrix" do
      sp1 = GSL::SparseMatrix.new 7, 3
      sp1[1, 1] = 1
      sp2 = GSL::SparseMatrix.new sp1
      sp2.type.should eq GSL::SparseMatrix::Type::COO
      sp2.should eq sp1
      sp1[1, 1] = 5
      sp2[1, 1].should eq 1
    end

    it "should create copy of matrix with given type" do
      sp1 = GSL::SparseMatrix.new 7, 3
      sp1[1, 1] = 1
      sp2 = GSL::SparseMatrix.new sp1, :csr
      sp2.type.should eq GSL::SparseMatrix::Type::CSR
      sp2[1, 1].should eq 1
    end

    it "should create sparse matrix from dense matrix" do
      sp1 = GSL::DenseMatrix.new 7, 3
      sp1[1, 1] = 1
      sp2 = GSL::SparseMatrix.new sp1, :csr
      sp2.type.should eq GSL::SparseMatrix::Type::CSR
      sp2[1, 1].should eq 1
    end
  end

  describe "#convert" do
    it "should convert matrix to given type" do
      sp1 = GSL::SparseMatrix.new 7, 3, :coo
      sp1[1, 2] = 3
      sp2 = sp1.convert(:csr)
      sp2.type.should eq GSL::SparseMatrix::Type::CSR
      sp2[1, 2].should eq 3
    end
    it "should return clone when type isn't changed" do
      sp1 = GSL::SparseMatrix.new 7, 3, :coo
      sp1[1, 2] = 3
      sp2 = sp1.convert(:coo)
      sp2.type.should eq GSL::SparseMatrix::Type::COO
      sp2[1, 2].should eq 3
    end
  end

  describe "#transpose" do
    it "should return transpose" do
      sp1 = GSL::SparseMatrix.new 7, 3
      sp1[1, 2] = 3
      sp2 = sp1.transpose
      sp2.type.should eq sp1.type
      sp2.shape.should eq({3, 7})
      sp2[2, 1].should eq 3
    end
  end
  describe "#transpose!" do
    it "should transpose inplace" do
      sp1 = GSL::SparseMatrix.new 7, 3
      sp1[1, 2] = 3
      sp1 = sp1.convert(:csr)
      sp1.transpose!
      sp1.shape.should eq({3, 7})
      sp1[2, 1].should eq 3
    end
  end

  describe "#to_dense" do
    it "returns dense matrix with same elements" do
      sp1 = GSL::SparseMatrix.new 7, 3
      sp1[1, 2] = 3
      sp2 = sp1.to_dense
      sp2[1, 2].should eq 3
      sp1[1, 1].should eq 0
    end
  end

  describe "#norm1" do
    it "returns zero for empty matrix" do
      test_matrix.norm1.should eq 0
    end
    it "returns norm1 value" do
      sp1 = GSL::SparseMatrix.new 7, 3
      sp1[1, 2] = -3
      sp1[2, 2] = 2
      sp1.norm1.should eq 5
    end
  end

  describe "#scale_columns" do
    it "scale columns by vector" do
      a = GSL::SparseMatrix.new 4, 3
      a[2, 0] = -3
      a[3, 1] = 2
      a.scale_columns! GSL::Vector.new [10.0, 20.0, 30.0]
      a[2, 0].should eq -30
      a[3, 1].should eq 40
    end
    it "scale columns by array" do
      a = GSL::SparseMatrix.new 4, 3
      a[2, 0] = -3
      a[3, 1] = 2
      a.scale_columns!([10.0, 20.0, 30.0])
      a[2, 0].should eq -30
      a[3, 1].should eq 40
    end
    it "should raise if dimensions don't match" do
      a = GSL::SparseMatrix.new 4, 3
      expect_raises(Exception) { a.scale_columns!([1.0, 2.0, 3.0, 4.0]) }
    end
  end

  describe "#scale_rows" do
    it "scale rows by vector" do
      a = GSL::SparseMatrix.new 4, 3
      a[0, 2] = -3
      a[1, 2] = 2
      a.scale_rows! GSL::Vector.new [10.0, 20.0, 30.0, 40.0]
      a[0, 2].should eq -30
      a[1, 2].should eq 40
    end
    it "scale rows by array" do
      a = GSL::SparseMatrix.new 4, 3
      a[0, 2] = -3
      a[1, 2] = 2
      a.scale_rows!([10.0, 20.0, 30.0, 40.0])
      a[0, 2].should eq -30
      a[1, 2].should eq 40
    end
    it "should raise if dimensions don't match" do
      a = GSL::SparseMatrix.new 7, 3
      expect_raises(Exception) { a.scale_rows!([4.0, 5.0, 6.0]) }
    end
  end

  describe "#min_index" do
    it "should find minimal element" do
      a = GSL::SparseMatrix.new 4, 3
      a[0, 2] = -3
      a[1, 2] = 2
      a.min_index.should eq({0, 2})
    end
    it "should find minimal element when all elements are positive" do
      a = GSL::SparseMatrix.new 4, 3
      a[0, 2] = 3
      a[1, 2] = 0
      a.min_index.should eq({1, 2})
    end
  end
end

describe GSL::DenseMatrix do
  describe "#add!" do
    it "should add! sparse matrix to dense" do
      a = GSL::DenseMatrix.new 5, 5
      a[1, 2] = 3
      a[2, 3] = 4
      b = GSL::SparseMatrix.new 5, 5
      b[1, 2] = -3
      b[3, 2] = -4

      a.add! b
      a[1, 2].should eq 0
      a[2, 3].should eq 4
      a[3, 2].should eq -4
    end
    it "should raise if dimensions don't match" do
      a = GSL::DenseMatrix.new 5, 4
      expect_raises(Exception) { a.add!(GSL::SparseMatrix.new(4, 5)) }
    end
  end

  describe "#sub!" do
    it "should sub! sparse matrix from dense" do
      a = GSL::DenseMatrix.new 5, 5
      a[1, 2] = 3
      a[2, 3] = 4
      b = GSL::SparseMatrix.new 5, 5
      b[1, 2] = 3
      b[3, 2] = 4

      a.sub! b
      a[1, 2].should eq 0
      a[2, 3].should eq 4
      a[3, 2].should eq -4
    end
    it "should raise if dimensions don't match" do
      a = GSL::DenseMatrix.new 5, 4
      expect_raises(Exception) { a.sub!(GSL::SparseMatrix.new(4, 5)) }
    end
  end
end
