require 'spec_helper'

describe ChronicDuration do

  describe ".parse" do

    @exemplars = {
      '1:20'                  => 60 + 20,
      '1:20.51'               => 60 + 20.51,
      '4:01:01'               => 4 * 3600 + 60 + 1,
      '3 mins 4 sec'          => 3 * 60 + 4,
      '3 Mins 4 Sec'          => 3 * 60 + 4,
      'three mins four sec'          => 3 * 60 + 4,
      '2 hrs 20 min'          => 2 * 3600 + 20 * 60,
      '2h20min'               => 2 * 3600 + 20 * 60,
      '6 mos 1 day'           => 6 * 22 * 8 * 3600 + 8 * 3600,
      '1 year 6 mos 1 day'    => 1 * 7488000 + 6 * 22 * 8 * 3600 + 8 * 3600,
      '2.5 hrs'               => 2.5 * 3600,
      '47 yrs 6 mos and 4.5d' => 47 * 7488000 + 6 * 22 * 8 * 3600 + 4.5 * 8 * 3600,
      'two hours and twenty minutes' => 2 * 3600 + 20 * 60,
      'four hours and forty minutes' => 4 * 3600 + 40 * 60,
      'four hours, and fourty minutes' => 4 * 3600 + 40 * 60,
      '3 weeks and, 2 days' => 3600 * 8 * 5 * 3 + 3600 * 8 * 2,
      '3 weeks, plus 2 days' => 3600 * 8 * 5 * 3 + 3600 * 8 * 2,
      '3 weeks with 2 days' => 3600 * 8 * 5 * 3 + 3600 * 8 * 2,
      '1 month'               => 3600 * 8 * 22,
      '2 months'              => 3600 * 8 * 22 * 2,
      '18 months'             => 3600 * 8 * 22 * 18,
      '1 year 6 months'       => (3600 * 8 * (260 + 6 * 22)).to_i,
      'day'                   => 3600 * 8,
      'minute 30s'            => 90
    }

    context "when string can't be parsed" do

      it "returns nil" do
        ChronicDuration.parse('gobblygoo').should be_nil
      end

      it "cannot parse zero" do
        ChronicDuration.parse('0').should be_nil
      end

      context "when @@raise_exceptions set to true" do

        it "raises with ChronicDuration::DurationParseError" do
          ChronicDuration.raise_exceptions = true
          expect { ChronicDuration.parse('23 gobblygoos') }.to raise_error(ChronicDuration::DurationParseError)
          ChronicDuration.raise_exceptions = false
        end

      end

    end

    it "should return zero if the string parses as zero and the keep_zero option is true" do
      ChronicDuration.parse('0', :keep_zero => true).should == 0
    end

    it "should return a float if seconds are in decimals" do
      ChronicDuration.parse('12 mins 3.141 seconds').is_a?(Float).should be_true
    end

    it "should return an integer unless the seconds are in decimals" do
      ChronicDuration.parse('12 mins 3 seconds').is_a?(Integer).should be_true
    end

    it "should be able to parse minutes by default" do
      ChronicDuration.parse('5', :default_unit => "minutes").should == 300
    end

    @exemplars.each do |k, v|
      it "parses a duration like #{k}" do
        ChronicDuration.parse(k).should == v
      end
    end

  end

  describe '.output' do

    @exemplars = {
      (60 + 20) =>
        {
          :micro    => '1min20s',
          :short    => '1min 20s',
          :default  => '1 min 20 secs',
          :long     => '1 minute 20 seconds',
          :chrono   => '1:20'
        },
      (60 + 20.51) =>
        {
          :micro    => '1min20.51s',
          :short    => '1min 20.51s',
          :default  => '1 min 20.51 secs',
          :long     => '1 minute 20.51 seconds',
          :chrono   => '1:20.51'
        },
      (60 + 20.51928) =>
        {
          :micro    => '1min20.51928s',
          :short    => '1min 20.51928s',
          :default  => '1 min 20.51928 secs',
          :long     => '1 minute 20.51928 seconds',
          :chrono   => '1:20.51928'
        },
      (4 * 3600 + 60 + 1) =>
        {
          :micro    => '4h1min1s',
          :short    => '4h 1min 1s',
          :default  => '4 hrs 1 min 1 sec',
          :long     => '4 hours 1 minute 1 second',
          :chrono   => '4:01:01'
        },
      (2 * 3600 + 20 * 60) =>
        {
          :micro    => '2h20min',
          :short    => '2h 20min',
          :default  => '2 hrs 20 mins',
          :long     => '2 hours 20 minutes',
          :chrono   => '2:20:00'
        },
      (6 * 22 * 8 * 3600 + 8 * 3600) =>
        {
          :micro    => '133d',
          :short    => '133d',
          :default  => '133 days',
          :long     => '133 days',
          :chrono   => '133:00:00:00' # Yuck. FIXME
        },
      (260 * 8 * 3600 + 8 * 3600 ).to_i =>
        {
          :micro    => '261d',
          :short    => '261d',
          :default  => '261 days',
          :long     => '261 days',
          :chrono   => '261:00:00:00'
        },
      (3 * 260 * 8 * 3600 + 8 * 3600 ).to_i =>
        {
          :micro    => '781d',
          :short    => '781d',
          :default  => '781 days',
          :long     => '781 days',
          :chrono   => '781:00:00:00'
        },
      (3600 * 8 * 22 * 18) =>
        {
          :micro    => '396d',
          :short    => '396d',
          :default  => '396 days',
          :long     => '396 days',
          :chrono   => '396:00:00:00'
        }
    }

    @exemplars.each do |k, v|
      v.each do |key, val|
        it "properly outputs a duration of #{k} seconds as #{val} using the #{key.to_s} format option" do
          ChronicDuration.output(k, :format => key).should == val
        end
      end
    end

    @keep_zero_exemplars = {
      (true) =>
      {
        :micro    => '0s',
        :short    => '0s',
        :default  => '0 secs',
        :long     => '0 seconds',
        :chrono   => '0'
      },
        (false) =>
      {
        :micro    => nil,
        :short    => nil,
        :default  => nil,
        :long     => nil,
        :chrono   => '0'
      },
    }

    @keep_zero_exemplars.each do |k, v|
      v.each do |key, val|
        it "should properly output a duration of 0 seconds as #{val.nil? ? "nil" : val} using the #{key.to_s} format option, if the keep_zero option is #{k.to_s}" do
          ChronicDuration.output(0, :format => key, :keep_zero => k).should == val
        end
      end
    end

    it "returns hours and minutes only when :hours_only option specified" do
      ChronicDuration.output(395*24*60*60 + 15*60, :limit_to_hours => true).should == '9480 hrs 15 mins'
    end

    it "returns the specified number of units if provided" do
      ChronicDuration.output(4 * 3600 + 60 + 1, units: 2).should == '4 hrs 1 min'
      ChronicDuration.output(6 * 22 * 8 * 3600 + 8 * 3600 + 3600 + 60 + 1, units: 3, format: :long).should == '133 days 1 hour 1 minute'
    end

    context "when the format is not specified" do

      it "uses the default format" do
        ChronicDuration.output(2 * 3600 + 20 * 60).should == '2 hrs 20 mins'
      end

    end

    @exemplars.each do |seconds, format_spec|
      format_spec.each do |format, _|
        it "outputs a duration for #{seconds} that parses back to the same thing when using the #{format.to_s} format" do
          ChronicDuration.parse(ChronicDuration.output(seconds, :format => format)).should == seconds
        end
      end
    end
    
    context "when the unit multiplier changes" do
      
    end
    
  end

  describe ".filter_by_type" do

    it "receives a chrono-formatted time like 3:14 and return a human time like 3 minutes 14 seconds" do
      ChronicDuration.instance_eval("filter_by_type('3:14')").should == '3 minutes 14 seconds'
    end

    it "receives chrono-formatted time like 12:10:14 and return a human time like 12 hours 10 minutes 14 seconds" do
      ChronicDuration.instance_eval("filter_by_type('12:10:14')").should == '12 hours 10 minutes 14 seconds'
    end

    it "returns the input if it's not a chrono-formatted time" do
      ChronicDuration.instance_eval("filter_by_type('4 hours')").should == '4 hours'
    end

  end

  describe ".cleanup" do

    it "cleans up extraneous words" do
      ChronicDuration.instance_eval("cleanup('4 days and 11 hours')").should == '4 days 11 hours'
    end

    it "cleans up extraneous spaces" do
      ChronicDuration.instance_eval("cleanup('  4 days and 11     hours')").should == '4 days 11 hours'
    end

    it "inserts spaces where there aren't any" do
      ChronicDuration.instance_eval("cleanup('4min11.5s')").should == '4 minutes 11.5 seconds'
    end

  end

end
