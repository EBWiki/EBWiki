# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'cases/show.html.erb', type: :view do
  before do
    controller.singleton_class.class_eval do
      protected

        def marker_locations_for(_cases)
          [Case.all]
        end
        helper_method :marker_locations_for
    end
  end
  describe 'on success' do
    it 'should not display a content field' do
      this_case = FactoryBot.create(:case)
      assign(:case, this_case)
      assign(:commentable, this_case)
      assign(:comments, this_case.comments)
      assign(:comment, Comment.new)
      assign(:subjects, this_case.subjects)
      assign(:state_objects, State.all)
      render
      expect(rendered).not_to match /only a stub/m
    end

    it 'displays litigation subheader if litigation text field is present' do
      this_case = FactoryBot.create(:case, litigation: 'Legal Action')

      assign(:case, this_case)
      assign(:commentable, this_case)
      assign(:comments, this_case.comments)
      assign(:comment, Comment.new)
      assign(:subjects, this_case.subjects)
      assign(:state_objects, State.all)
      render
      expect(response.body).to match /Legal Action/m
    end

    it 'displays summary subheader if overview text field is present' do
      this_case = FactoryBot.create(:case, overview: 'overview text')

      assign(:case, this_case)
      assign(:commentable, this_case)
      assign(:comments, this_case.comments)
      assign(:comment, Comment.new)
      assign(:subjects, this_case.subjects)
      assign(:state_objects, State.all)
      render
      expect(response.body).to match /Summary/m
    end

    it 'displays community action subheader if overview text field is present' do
      this_case = FactoryBot.create(:case, community_action: 'community text')

      assign(:case, this_case)
      assign(:commentable, this_case)
      assign(:comments, this_case.comments)
      assign(:comment, Comment.new)
      assign(:subjects, this_case.subjects)
      assign(:state_objects, State.all)
      render
      expect(response.body).to match /Community and Family/m
    end
  end
end
