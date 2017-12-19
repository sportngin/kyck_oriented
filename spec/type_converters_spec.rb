require 'spec_helper'
module Oriented
  module TypeConverters
    describe ".convert" do
       it "returns a default converter" do
        Oriented::TypeConverters.convert("test").should == "test"
       end

       it "converts a symbol" do
         Oriented::TypeConverters.convert(:test).should == "test"
       end

       it "converts a Fixnum" do
         Oriented::TypeConverters.convert(101).should == 101
       end

       it "converts a DateTime" do
         dt = Time.utc(2013, 12, 30).to_datetime
         Oriented::TypeConverters.convert(dt).time.should == dt.to_time.to_i*1000
       end

       it "converts a Date" do
         dt = Time.utc(2013, 12, 30).to_date
         Oriented::TypeConverters.convert(dt).time.should == dt.to_time.to_i*1000
       end

       it "converts a Set" do
         set = Set.new([1,2,3])
         Oriented::TypeConverters.convert(set).should == Java::JavaUtil::HashSet.new([ 1,2,3 ])
       end

       it "converts a Hash" do
         set =  {a: 1, b: 2, c: 3}
         Oriented::TypeConverters.convert(set).should == {a: 1, b:2, c:3}.stringify_keys.to_java
       end
    end

    describe ".converter" do
      context "for a symbol" do
        it "returns a SymbolConverter" do
          Oriented::TypeConverters.converter(:symbol).should  == SymbolConverter
        end
      end
    end


    describe DateTimeConverter do
      describe ".to_ruby" do
        it "converts java to ruby" do
          exp_dt = Time.utc(2013, 12, 30).to_datetime
          dt = Java::JavaUtil::Date.new(exp_dt.to_time.to_i * 1000)
          DateTimeConverter.to_ruby(dt).should == exp_dt
        end
      end

    end

    describe DateConverter do
      describe ".to_ruby" do
        it "converts java to ruby" do
          exp_dt = Time.utc(2013, 12, 30).to_date
          dt = Java::JavaUtil::Date.new(exp_dt.to_time.to_i * 1000)
          DateConverter.to_ruby(dt).should == exp_dt
        end
      end

      describe '.to_java' do
        context "with 2 digit year" do
          it "converts a string with and 2 digit month slashes" do
            exp_dt = Time.utc(2000, 1, 7).to_date
            dt = '01/07/00'
            DateConverter.to_java(dt).time.should == exp_dt.to_time.to_i*1000
          end
          it "converts a string with slashes and 1-digit month/day" do
            exp_dt = Time.utc(2000, 1, 7).to_date
            dt = '1/7/00'
            DateConverter.to_java(dt).time.should == exp_dt.to_time.to_i*1000
          end
          it "converts a string with slashes" do
            exp_dt = Time.utc(2000, 12, 7).to_date
            dt = '12/7/00'
            DateConverter.to_java(dt).time.should == exp_dt.to_time.to_i*1000
          end
          it "converts a string with dashess" do
            exp_dt = Time.utc(2000, 1, 7).to_date
            dt = '01-07-00'
            DateConverter.to_java(dt).time.should == exp_dt.to_time.to_i*1000
          end
        end
        context "with 4 digit year" do
          it "converts a string with slashes" do
            exp_dt = Time.utc(2000, 1, 7).to_date
            dt = '01/07/2000'
            DateConverter.to_java(dt).time.should == exp_dt.to_time.to_i*1000
          end
          it "converts a string with dashess" do
            exp_dt = Time.utc(2000, 1, 7).to_date
            dt = '01-07-2000'
            DateConverter.to_java(dt).time.should == exp_dt.to_time.to_i*1000
          end
          it "converts a string with dashess" do
            exp_dt = Time.utc(2000, 1, 7).to_date
            dt = '1-7-2000'
            DateConverter.to_java(dt).time.should == exp_dt.to_time.to_i*1000
          end
          it "converts a string with dashess" do
            exp_dt = Time.utc(2000, 1, 7).to_date
            dt = '1-07-2000'
            DateConverter.to_java(dt).time.should == exp_dt.to_time.to_i*1000
          end
        end
      end
    end

    describe TimeConverter do
      describe ".to_ruby" do
        it "converts java to ruby" do
          exp_dt = Time.new(2013, 12, 30)
          dt = Java::JavaUtil::Date.new(exp_dt.to_time.to_i * 1000)
          TimeConverter.to_ruby(dt).should == exp_dt
        end
      end
    end

    describe SymbolConverter do
      describe ".to_ruby" do
        it "converts java to ruby" do
          SymbolConverter.to_ruby("symbol").should == :symbol
        end
      end
    end
  end
end
