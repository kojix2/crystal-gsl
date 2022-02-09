require "./spec_helper"

length_ten_vector = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].to_vector
length_four_vector = [1, 2, 3, 4].to_vector
describe GSL::Vector do
  describe "#+" do
    it "should add every element with input integer" do
      (length_four_vector + 10).should eq(GSL::Vector.new [11.0, 12.0, 13.0, 14.0])
    end
    it "should add every element with input float" do
      (length_four_vector + 10.0).should eq(GSL::Vector.new [11.0, 12.0, 13.0, 14.0])
    end
    it "should add two vectors together" do
      (length_four_vector + [1, 2, 3, 4].to_vector).should eq(GSL::Vector.new [2.0, 4.0, 6.0, 8.0])
    end
  end
  describe "#-" do
    it "should sub every element with input integer" do
      (length_four_vector - 1).should eq(GSL::Vector.new [0.0, 1.0, 2.0, 3.0])
    end
    it "should sub every element with input float" do
      (length_four_vector - 1.0).should eq(GSL::Vector.new [0.0, 1.0, 2.0, 3.0])
    end
    it "should sub two vectors together" do
      (length_four_vector - [1, 2, 3, 4].to_vector).should eq(GSL::Vector.new [0.0, 0.0, 0.0, 0.0])
    end
  end
  describe "#*" do
    it "should scale every element with input integer" do
      (length_four_vector * 2).should eq(GSL::Vector.new [2.0, 4.0, 6.0, 8.0])
    end
    it "should scale every element with input float" do
      (length_four_vector * 2.0).should eq(GSL::Vector.new [2.0, 4.0, 6.0, 8.0])
    end
    it "should multiply two vectors together" do
      (length_four_vector * [1, 2, 3, 4].to_vector).should eq(GSL::Vector.new [1.0, 4.0, 9.0, 16.0])
    end
  end
  describe "#/" do
    it "should divide every element with input integer" do
      (length_four_vector / 2).should eq(GSL::Vector.new [0.5, 1.0, 1.5, 2.0])
    end
    it "should divide every element with input float" do
      (length_four_vector / 2.0).should eq(GSL::Vector.new [0.5, 1.0, 1.5, 2.0])
    end
    it "should divide two vectors together" do
      (length_four_vector / [1, 2, 3, 4].to_vector).should eq(GSL::Vector.new [1.0, 1.0, 1.0, 1.0])
    end
  end
  describe "#head" do
    it "should return first five data of a vector" do
      length_ten_vector.head.should eq(GSL::Vector.new [1.0, 2.0, 3.0, 4.0, 5.0])
    end

    it "should return it self if the data is not long enough" do
      length_four_vector.head.should eq(GSL::Vector.new [1.0, 2.0, 3.0, 4.0])
    end
  end
  describe "#tail" do
    it "should return last five data of a vector" do
      length_ten_vector.tail.should eq(GSL::Vector.new [6.0, 7.0, 8.0, 9.0, 10.0])
    end

    it "should return it self if the data is not long enough" do
      length_four_vector.tail.should eq(GSL::Vector.new [1.0, 2.0, 3.0, 4.0])
    end
  end
  describe "#first" do
    it "should return the first element of vector" do
      length_four_vector.first.should eq 1.0
    end
  end
  describe "#last" do
    it "should return the last element of vector" do
      length_four_vector.last.should eq 4.0
    end
  end
  describe "#to_array" do
    it "should return the data of this vector" do
      length_four_vector.to_array.should eq [1.0, 2.0, 3.0, 4.0]
    end
    it "should return the data of this vector" do
      length_four_vector.to_a.should eq [1.0, 2.0, 3.0, 4.0]
    end
  end
  describe "#push" do
    it "should push data to the last of vector" do
      (length_four_vector.push 5).should eq(GSL::Vector.new [1.0, 2.0, 3.0, 4.0, 5.0])
    end
    it "should push data to the last of vector" do
      (length_four_vector << 5).should eq(GSL::Vector.new [1.0, 2.0, 3.0, 4.0, 5.0])
    end
  end
  describe "#includes?" do
    it "should return true if the data is in the vector" do
      (length_four_vector.includes? 4).should eq true
    end
    it "should return true if the data is in the vector" do
      (length_four_vector.includes? 4.0).should eq true
    end
    it "should return false if the data is not in the vector" do
      (length_four_vector.includes? 5).should eq false
    end
    it "should return false if the data is not in the vector" do
      (length_four_vector.includes? 5.0).should eq false
    end
  end
  describe "#concat" do
    it "should concatenate two vectors together" do
      (length_four_vector.concat length_ten_vector).should eq(GSL::Vector.new [1.0, 2.0, 3.0, 4.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0])
    end
  end
  describe "#sort" do
    it "should return the sorted vector" do
      (GSL::Vector.new [4.0, 3.0, 2.0, 1.0]).sort.should eq length_four_vector
    end
  end
  describe "#replace" do
    it "should replace itself by the input vector" do
      ((GSL::Vector.new [1.0, 2.0, 3.0, 4.0]).replace(GSL::Vector.new [4.0, 3.0, 2.0, 1.0])).should eq(GSL::Vector.new [4.0, 3.0, 2.0, 1.0])
    end
  end
  describe "#reverse" do
    it "should return a reversed vector" do
      length_four_vector.reverse.should eq(GSL::Vector.new [4.0, 3.0, 2.0, 1.0])
    end
  end
  describe "#max" do
    it "should return the maximum of vector" do
      length_four_vector.max.should eq 4.0
    end
  end
  describe "#min" do
    it "should return the minimum of vector" do
      length_four_vector.min.should eq 1.0
    end
  end
  describe "#minmax" do
    it "should return a array for minimun value and maximum value of vector" do
      length_four_vector.minmax.should eq [1.0, 4.0]
    end
  end
  describe "#max_index" do
    it "should return the index of maximum value of vector" do
      length_four_vector.max_index.should eq 3
    end
  end
  describe "#min_index" do
    it "should return the index of minimum value of vector" do
      length_four_vector.min_index.should eq 0
    end
  end
  describe "#minmax_index" do
    it "should return a array for index of minimun value and maximum value of vector" do
      length_four_vector.minmax_index.should eq [0, 3]
    end
  end
  describe "#empty?" do
    it "should return true if all the elements are zero" do
      (GSL::Vector.new [0.0, 0.0, 0.0]).empty?.should eq true
    end
    it "should return false if some the elements are not zero" do
      length_four_vector.empty?.should eq false
    end
  end
  describe "#pos?" do
    it "should return true if all the elements are positive" do
      length_four_vector.pos?.should eq true
    end
    it "should return false if some the elements are not positive" do
      (GSL::Vector.new [0.0, 0.0, 0.0]).pos?.should eq false
    end
  end
  describe "#neg?" do
    it "should return true if all the elements are negtive" do
      (GSL::Vector.new [-1.0, -1.0, -1.0]).neg?.should eq true
    end
    it "should return false if some the elements are not negtive" do
      (GSL::Vector.new [0.0, 0.0, 0.0]).neg?.should eq false
    end
  end
  describe "#has_neg?" do
    it "should return true if some the elements are negtive" do
      (GSL::Vector.new [0.0, 0.0, -1.0]).has_neg?.should eq true
    end
    it "should return false if all the elements are not negtive" do
      length_four_vector.has_neg?.should eq false
    end
  end
  describe "#set_zero" do
    it "should set all the values of this vector to zero" do
      (GSL::Vector.new [-1.0, -1.0, -1.0]).set_zero.should eq(GSL::Vector.new [0.0, 0.0, 0.0])
    end
  end
  describe "#set_all" do
    it "should set all the values of this vector to sepecific value" do
      (GSL::Vector.new [-1.0, -1.0, -1.0]).set_all(5).should eq(GSL::Vector.new [5.0, 5.0, 5.0])
    end
  end
  describe "#set_bias" do
    it "should set all the values to zero except the chosen indexto one" do
      (GSL::Vector.new [-1.0, -1.0, -1.0]).set_basis(2).should eq(GSL::Vector.new [0.0, 0.0, 1.0])
    end
  end
  describe "#mean" do
    it "should return the correct mean" do
      (GSL::Vector.new [0.0, -5.0, 7.3]).mean.should eq 0.76666666666666661
    end
  end
end
