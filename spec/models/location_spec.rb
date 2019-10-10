require 'rspec'

describe Location do
  context "when optional params are present" do
    it "should return address" do
      location = Location.new(city: "Bangalore", state: "Karnataka", street_location: "21st, MG road", zipcode: "560078")

      expect(location.to_s).to eq("21st, MG road, Bangalore, Karnataka, 560078")
    end
  end

  context "when optional params are not present" do
    it "should return address" do
      location = Location.new(state: "Karnataka")

      expect(location.to_s).to eq("Karnataka")
    end

    it "should raise error if state is not present in location" do
      expect { Location.new(city: "Bangalore") }.to raise_error(ArgumentError)
    end
  end

  context "when location is compared" do
    it "should return true if locations are same" do
      location1 = Location.new(city: "Bangalore", state: "Karnataka", street_location: "21st, MG road", zipcode: "560078")
      location2 = Location.new(city: "Bangalore", state: "Karnataka", street_location: "21st, MG road", zipcode: "560078")

      expect(location1 == location2).to be_truthy
    end

    it "should return false if locations are different" do
      location1 = Location.new(city: "Bangalore", state: "Karnataka", street_location: "21st, MG road", zipcode: "560078")
      location2 = Location.new(city: "Bangalore", state: "Karnataka", street_location: "22nd, MG road", zipcode: "560078")

      expect(location1 == location2).to be_falsey
    end
  end

  context "when location with only state" do
    it "should return true if both state of locations are same" do
      location1 = Location.new(state: "Karnataka")
      location2 = Location.new(state: "Karnataka")

      expect(location1 == location2).to be_truthy
    end
  end
end
