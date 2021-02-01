RSpec.describe CaseSearch do
  describe "#call" do
    it "returns all cases when given no arguments" do
      case_1 = create(:case, title: 'cheese')
      case_2 = create(:case, title: 'burger')
      Case.reindex
      expect(CaseSearch.new.call.to_a).to eq([case_1, case_2])
    end

    it "returns cases matching a given query" do
      case_1 = create(:case, title: 'cheese')
      case_2 = create(:case, title: 'burger')
      Case.reindex
      expect(CaseSearch.new(query: 'burger').call.to_a).to eq([case_2])
    end

    context "when given a state_id" do
      it "returns cases matching the given state_id" do
        case_1 = create(:case, title: 'cheese')
        case_2 = create(:case, title: 'burger')
        Case.reindex
        options = { state_id: case_2.state_id }
        expect(CaseSearch.new(options: options).call.to_a).to eq([case_2])
      end

      it "sorts cases by date descending" do
        case_1 = create(:case, title: 'cheese', date: 1.week.ago)
        case_2 = create(:case, title: 'burger', state: case_1.state)
        Case.reindex
        options = { state_id: case_1.state_id }
        expect(CaseSearch.new(options: options).call.to_a).to eq([case_2, case_1])
      end
    end

    it "returns cases on the given page" do
      cases = create_list(:case, 13)
      Case.reindex
      expect(CaseSearch.new(options: { page: 2 }).call.to_a).to eq([cases.last])
    end
  end
end
