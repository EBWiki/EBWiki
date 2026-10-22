# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Memorial photos accessibility', :js do
  before { WebMock.disable_net_connect!(allow_localhost: true) }

  it 'has no serious or critical axe violations' do
    state = create(:state)
    create(:case, :memorial_photo_shown, title: 'Accessible Case', state: state)

    visit memorial_photos_path

    expect(page).to have_content('Memorial')
    expect_no_serious_or_critical_axe_violations(page)
  end
end
