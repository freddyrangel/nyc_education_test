require 'rails_helper'

RSpec.describe School, type: :model do

  describe 'relations' do
    it { should have_many(:api_school_datas) }
    it { should have_many(:school_datas) }
  end

  describe 'strip punctuation' do
    it "strips" do
      school = build(:school, name: "P.S. 003")
      school.save
      school.reload
      expect(School.last.name).to  eq("PS 003")
    end
  end

  describe 'full_street_address' do

    let(:school) { create(:school) }

    it "should return full street address" do
      address = school.primary_address + ", " + school.city + ", " + school.zip
      expect(school.full_street_address).to eq(address)
    end
  end

  describe 'search_by_name_or_dbn' do

    let!(:school) { create(:school, name: "School Name") }

    it "returns by dbn_id" do
      result = School.search_by_name_or_dbn(school.dbn_id)
      expect(result).to eq([school])
    end

    it "returns by name" do
      result = School.search_by_name_or_dbn(school.name)
      expect(result).to eq([school])
    end

    it "returns a partial name search" do
      result = School.search_by_name_or_dbn("School")
      expect(result).to eq([school])
    end

    it "should return multiple partial matches" do
      school_two = create(:school, name: "Second School Name")
      result = School.search_by_name_or_dbn("School")
      expect(result).to eq([school, school_two])
    end

    it "stills returns a unique result" do
      school_two = create(:school, name: "School Name Second ")
      result = School.search_by_name_or_dbn("Second")
      expect(result).to eq([school_two])
    end

    it "should disregard character case" do
      school_two = create(:school, name: "School Name Second ")
      result = School.search_by_name_or_dbn("SeCoNd")
      expect(result).to eq([school_two])
    end
  end

  describe 'search_results' do
    it "should join two search results" do
      school_one = create(:school, name: "ps 003", dbn: "123455678")
      school_two = create(:school, name: "ps3", dbn: '87654321')
      search_params = 'ps3'
      results = School.search_results(search_params)
      expect(results).to eq([school_one, school_two])
    end
  end
end
