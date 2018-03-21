# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'cases/show.html.erb', type: :view do
  before do
    allow(view).to receive(:marker_locations_for).and_return([Case.all])
  end

  it 'should not display a content field' do
    this_case = FactoryBot.create(:case)
    assign(:this_case, this_case)
    assign(:commentable, this_case)
    assign(:comments, this_case.comments)
    assign(:comment, Comment.new)
    assign(:subjects, this_case.subjects)
    assign(:state_objects, State.all)
    render
    expect(rendered).not_to match(/only a stub/m)
  end
end

RSpec.describe 'cases/show.html.erb', type: :view do
  before do
    allow(view).to receive(:marker_locations_for).and_return([Case.all])
  end

  it 'displays litigation subheader if litigation text field is present' do
    this_case = FactoryBot.create(:case, litigation: 'Legal Action')

    assign(:this_case, this_case)
    assign(:commentable, this_case)
    assign(:comments, this_case.comments)
    assign(:comment, Comment.new)
    assign(:subjects, this_case.subjects)
    assign(:state_objects, State.all)
    render
    expect(response.body).to match(/Legal Action/m)
  end
end
RSpec.describe 'cases/show.html.erb', type: :view do
  before do
    allow(view).to receive(:marker_locations_for).and_return([Case.all])
  end

  it 'displays summary subheader if overview text field is present' do
    this_case = FactoryBot.create(:case, overview: 'overview text')

    assign(:this_case, this_case)
    assign(:commentable, this_case)
    assign(:comments, this_case.comments)
    assign(:comment, Comment.new)
    assign(:subjects, this_case.subjects)
    assign(:state_objects, State.all)
    render
    expect(response.body).to match(/Summary/m)
  end
end
RSpec.describe 'cases/show.html.erb', type: :view do
  before do
    allow(view).to receive(:marker_locations_for).and_return([Case.all])
  end

  it 'displays community action subheader if overview text field is present' do
    this_case = FactoryBot.create(:case, community_action: 'community text')

    assign(:this_case, this_case)
    assign(:commentable, this_case)
    assign(:comments, this_case.comments)
    assign(:comment, Comment.new)
    assign(:subjects, this_case.subjects)
    assign(:state_objects, State.all)
    render
    expect(response.body).to match(/Community and Family/m)
  end
end
