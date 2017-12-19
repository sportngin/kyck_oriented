require_relative '../fixtures/models'
require 'spec_helper'
require 'time'

shared_examples_for 'attributes round-trip' do
  it 'saves to the database' do
    expect {
      subject.save!
    }.to_not raise_error
  end

  it 'loads from the database' do
    subject.save!
    model = described_class.find(subject.id)
    props = subject.props
    props['hash'].stringify_keys! if props['hash']
    props['hash_dflt'].stringify_keys! if props['hash_dflt']
    expect(model.props).to eql(props)
  end
end

shared_context 'property converters' do
  let(:args) { [attributes] }
  let(:attributes) { {} }
  subject { described_class.new(*args) }
end

shared_examples_for 'default values' do
  it 'has default values' do
    defaults = {
      'default'     => nil,
      'fixnum'      => nil,
      'symbol'      => nil,
      'date'        => nil,
      'datetime'    => nil,
      'time'        => nil,
      'bool'        => nil,
      'float'       => nil,
      'set'         => nil,
      'hash'        => nil,
      'array'       => nil,
      'fixnum_dflt' => described_class.attribute_defaults['fixnum_dflt'],
      'symbol_dflt' => described_class.attribute_defaults['symbol_dflt'],
      'date_dflt'   => described_class.attribute_defaults['date_dflt'],
      'datetime_dflt' => described_class.attribute_defaults['datetime_dflt'],
      'time_dflt'   => described_class.attribute_defaults['time_dflt'],
      'bool_dflt'   => described_class.attribute_defaults['bool_dflt'],
      'float_dflt'  => described_class.attribute_defaults['float_dflt'],
      'set_dflt'    => described_class.attribute_defaults['set_dflt'],
      'hash_dflt'   => described_class.attribute_defaults['hash_dflt'],
      'array_dflt'  => described_class.attribute_defaults['array_dflt']
    }.keep_if {|k, v| described_class._props.key?(k) }

    expect(subject.props).to eql(defaults)
  end
end

sample_attribute_values = {
  'default'     => 'hello',
  'fixnum'      => 20,
  'symbol'      => :dude,
  'date'        => Time.utc(2017, 12, 21, 16, 28, 0, 0).to_date,
  'datetime'    => Time.utc(2017, 12, 21, 16, 28, 0, 0).to_datetime,
  'time'        => Time.utc(2017, 12, 21, 16, 28, 0, 0),
  'bool'        => false,
  'float'       => 10.1,
  'set'         => Set.new(["1", 1, 2, 3, 5, 8, true]),
  'hash'        => { message: 'General greeting', level: 'INFO' },
  'array'       => [1, 2, 1, 2],
}

[:fixnum, :symbol, :date, :datetime, :time, :bool, :float, :set, :hash, :array].each do |type, value|
  describe define_vertex_property_converter(type) do
    include_context 'property converters'

    it_behaves_like 'default values'

    describe 'with defaults' do
      it_behaves_like 'attributes round-trip'
    end

    describe 'with a sample value' do
      let(:attributes) { { type.to_s => sample_attribute_values[type.to_s] } }

      it_behaves_like 'attributes round-trip'
    end
  end

  describe define_edge_property_converter(type) do
    include_context 'property converters'

    let(:start_vertex) { described_class.vertex_type.create }
    let(:end_vertex)   { described_class.vertex_type.create }
    let(:args) { [start_vertex, end_vertex, described_class.name, attributes] }

    it_behaves_like 'default values'

    describe 'with defaults' do
      it_behaves_like 'attributes round-trip'
    end

    describe 'with a sample value' do
      let(:attributes) { { type.to_s => sample_attribute_values[type.to_s] } }

      it_behaves_like 'attributes round-trip'
    end
  end
end

describe AllVertexProperties do
  before(:all) { define_vertex_type described_class.name }

  include_context 'property converters'

  let(:attributes) { sample_attribute_values }

  it_behaves_like 'attributes round-trip'
end

describe AllEdgeProperties do
  before(:all) { define_edge_type described_class.name }

  include_context 'property converters'

  let(:start_vertex) { AllVertexProperties.create }
  let(:end_vertex)   { AllVertexProperties.create }
  let(:args) { [start_vertex, end_vertex, described_class.name, attributes] }

  let(:attributes) { sample_attribute_values }

  it_behaves_like 'attributes round-trip'
end

