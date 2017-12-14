require 'spec_helper'
require_relative "../fixtures/models"

describe "WriteRelationships" do

  let(:model) {Model.new(name: "Barbie")}
  let(:stylist1) {Stylist.new(name: 'Style1')}
  let(:stylist2) {Stylist.new(name: 'Style2')}
  let(:stylist3) {Stylist.new(name: 'Style3')}
  let(:agency) {Agency.new}

  before do
    %w(Model DrugDealer Stylist ModelingRequest Agency).each do |vt|
      Oriented.graph.ensure_vertex_type(vt)
    end
    %w(drug_dealer stylists requests target guru issuer).each do |vt|
      Oriented.graph.ensure_edge_type(vt)
    end
  end
  context "when issueing a modeling request" do

    before do
      model.stylists << stylist1
      model.stylists << stylist2
      model.save
      model.stylists.count.should == 2
      Oriented.graph.commit
    end

    it "doesn't blow away other relationships on the model" do
      m = Model.get!(model.id)
      mr = ModelingRequest.new
      mr.target = m
      mr.guru = stylist3
      mr.issuer = agency

      mr.save
      Oriented.graph.commit
      m = Model.get!(model.id)
      m.stylists.count.should ==2
    end


  end
end
