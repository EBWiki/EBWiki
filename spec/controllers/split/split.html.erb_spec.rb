require 'rails_helper'

RSpec.describe "split.html.erb", type: :view do

  describe "before authentication" do
    it 'displays a login screen before authentication' do
      get 'split'
      expect(rendered).to match(/you must log in/m)
    end
  end
end