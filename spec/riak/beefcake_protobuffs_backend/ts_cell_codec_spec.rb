require 'spec_helper'
require 'bigdecimal'
require 'time'

Riak::Client::BeefcakeProtobuffsBackend.configured?

describe Riak::Client::BeefcakeProtobuffsBackend::TsCellCodec do
  describe 'symmetric serialziation' do
    it { is_expected.to symmetric_serialize("hello", binary_value: "hello")}
    it { is_expected.to symmetric_serialize(5, integer_value: 5)}
    it { is_expected.to symmetric_serialize(123.45, double_value: 123.45) }
    it { is_expected.to symmetric_serialize((2**64),
                                  numeric_value: "18446744073709551616") }
    it do
      is_expected.to symmetric_serialize(Time.parse("June 23, 2015 at 9:46:28 EDT"),
                                         timestamp_value: 1435067188000)
    end
    it { is_expected.to symmetric_serialize(true, boolean_value: true) }
    it { is_expected.to symmetric_serialize(false, boolean_value: false) }
    it { is_expected.to symmetric_serialize(nil, {}) }
  end

  describe 'serializing values' do
    it do
      is_expected.to serialize(BigDecimal.new("0.1"), numeric_value: "0.1E0")
    end

    it 'refuses to serialize complex numbers' do
      expect{ subject.cell_for(Complex(1, 1)) }.
        to raise_error Riak::TimeSeriesError::SerializeComplexNumberError
    end

    it 'refuses to serialize rational numbers' do
      expect{ subject.cell_for(Rational(1, 1)) }.
        to raise_error Riak::TimeSeriesError::SerializeRationalNumberError
    end
  end

  # these are handled by the symmetric cases above
  # describe 'deserializing values'

  RSpec::Matchers.define :symmetric_serialize do |scalar, cell_options|
    match do |codec|
      expect(codec).to(
        serialize(scalar, cell_options)
        .and(deserialize(scalar, cell_options)))
    end

    failure_message do |codec|
      cell = Riak::Client::BeefcakeProtobuffsBackend::TsCell.new cell_options
      deserialized = codec.scalar_for cell
      "expected #{scalar} => #{cell_options} => #{scalar}, got #{scalar} => #{cell.to_hash} => #{deserialized}"
    end

    description do
      "serialize #{scalar.class} #{scalar.inspect} to and from TsCell #{cell_options}"
    end
  end

  RSpec::Matchers.define :serialize do |measure, options|
    match do |actual|
      serialized = actual.cell_for(measure)
      serialized.to_hash == options
    end

    failure_message do |actual|
      serialized = actual.cell_for(measure)
      "expected #{options}, got #{serialized.to_hash}"
    end

    description do
      "serialize #{measure.class} #{measure.inspect} to TsCell #{options}"
    end
  end

  RSpec::Matchers.define :deserialize do |expected, options|

    cell = Riak::Client::BeefcakeProtobuffsBackend::TsCell.new options

    match do |codec|
      deserialized = codec.scalar_for cell
      deserialized == expected
    end

    failure_message do |codec|
      deserialized = codec.scalar_for cell
      "expected TsCell #{options.inspect} to deserialize to #{expected.class} #{expected.inspect}"
    end

    description do
      "deserialize TsCell #{options} to #{expected.class} #{expected.inspect}"
    end
  end
end