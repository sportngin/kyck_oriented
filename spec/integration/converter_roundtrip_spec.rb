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
    expect(model.props).to eql(subject.props)
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
      'time'        => nil,
      'bool'        => nil,
      'float'       => nil,
      'set'         => nil,
      'hash'        => nil,
      'array'       => nil,
      'fixnum_dflt' => described_class.attribute_defaults['fixnum_dflt'],
      'symbol_dflt' => described_class.attribute_defaults['symbol_dflt'],
      'date_dflt'   => described_class.attribute_defaults['date_dflt'],
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

[:fixnum, :symbol, :date, :time, :bool, :float, :set, :hash, :array].each do |type|
  describe define_vertex_property_converter(type) do
    include_context 'property converters'

    it_behaves_like 'default values'

    describe 'with defaults' do
      it_behaves_like 'attributes round-trip'
    end
  end

  describe define_edge_property_converter(type) do
    include_context 'property converters'

    let(:start_vertex) { described_class.vertex_type.create }
    let(:end_vertex) { described_class.vertex_type.create }
    let(:args) {[start_vertex, end_vertex, described_class.name, attributes] }

    before { Oriented.graph.commit }

    it_behaves_like 'default values'

    describe 'with defaults' do
      it_behaves_like 'attributes round-trip'
    end
  end
end
