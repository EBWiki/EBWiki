require 'rspec'

describe Location do
  context "when all location params are present" do
    it "returns address as inline" do
      location = Location.new(city: "Bangalore", state: "Karnataka", street_location: "21st, MG road", zipcode: "560078")

      expect(location.to_s).to eq("21st, MG road, Bangalore, Karnataka, 560078")
    end

    context "when letter_style is true" do
      it "returns address with letter style" do
        location = Location.new(city: "Bangalore", state: "Karnataka", street_location: "21st, MG road", zipcode: "560078")

        expect(location.to_s(letter_style: true)).to eq("21st, MG road\nBangalore, Karnataka 560078")
      end
    end
  end

  context "when all location params are not present" do
    it "returns address with provided params" do
      location = Location.new(state: "Karnataka")

      expect(location.to_s).to eq("Karnataka")
    end

    it "raises error if state is not present in location" do
      expect { Location.new(city: "Bangalore") }.to raise_error(ArgumentError)
    end
  end

  context "when location is compared" do
    it "returns true if locations are identical" do
      location1 = Location.new(city: "Bangalore", state: "Karnataka", street_location: "21st, MG road", zipcode: "560078")
      location2 = Location.new(city: "Bangalore", state: "Karnataka", street_location: "21st, MG road", zipcode: "560078")

      expect(location1 == location2).to be_truthy
    end

    it "returns false if locations are not identical" do
      location1 = Location.new(city: "Bangalore", state: "Karnataka", street_location: "21st, MG road", zipcode: "560078")
      location2 = Location.new(city: "Bangalore", state: "Karnataka", street_location: "22nd, MG road", zipcode: "560078")

      expect(location1 == location2).to be_falsey
    end

    context "when location with only states" do
      it "returns true when both states are identical" do
        location1 = Location.new(state: "Karnataka")
        location2 = Location.new(state: "Karnataka")

        expect(location1 == location2).to be_truthy
      end
    end
  end
end
