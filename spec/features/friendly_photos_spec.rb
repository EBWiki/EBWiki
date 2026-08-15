# frozen_string_literal: true

require 'rails_helper'

feature 'Friendly photos' do
  let(:user) { create(:user) }
  let!(:missing_case) { create(:case, title: 'Missing Photo Case') }
  let!(:mugshot_case) { create(:case, title: 'Mugshot Case', avatar_kind: 'mugshot') }
  let!(:portrait_case) { create(:case, title: 'Portrait Case', avatar_kind: 'portrait') }

  before do
    create(:subject, case: missing_case, name: 'Jordan Doe')
    create(:subject, case: mugshot_case, name: 'Riley Mugshot')
    create(:subject, case: portrait_case, name: 'Casey Portrait')
    portrait_case.update_columns(avatar: 'uploads/case/avatar/9/family_portrait.jpg')
  end

  scenario 'a guest is sent to login' do
    visit friendly_photos_path
    expect(page).to have_current_path(new_user_session_path)
  end

  scenario 'an editor sees people who still need a dignified photo' do
    sign_in user
    visit friendly_photos_path

    expect(page).to have_content('Friendly photos')
    expect(page).to have_content('Jordan Doe')
    expect(page).to have_content('Riley Mugshot')
    expect(page).not_to have_content('Casey Portrait')
    expect(page).to have_css('[data-testid="friendly-photos-nav"]')
  end

  scenario 'filters separate missing, mugshot, and portrait cases' do
    sign_in user
    visit friendly_photos_path(filter: 'missing')
    expect(page).to have_content('Jordan Doe')
    expect(page).not_to have_content('Casey Portrait')
    # A mugshot case with no stored file also matches the missing filter.
    expect(page).to have_content('Riley Mugshot')

    visit friendly_photos_path(filter: 'mugshot')
    expect(page).to have_content('Riley Mugshot')
    expect(page).not_to have_content('Jordan Doe')

    visit friendly_photos_path(filter: 'portrait')
    expect(page).to have_content('Casey Portrait')
  end

  scenario 'the case page offers a find-photo link when one is needed' do
    sign_in user
    visit case_path(missing_case)
    expect(page).to have_css('[data-testid="find-friendly-photo"]')

    visit case_path(portrait_case)
    expect(page).not_to have_css('[data-testid="find-friendly-photo"]')
  end

  scenario 'the edit form links to the Wikimedia search' do
    sign_in user
    visit edit_case_path(missing_case)
    expect(page).to have_css('[data-testid="edit-search-friendly-photo"]')
    expect(page).to have_content('What kind of photo is this?')
  end

  scenario 'an editor classifies the current photo as a mugshot' do
    sign_in user
    visit friendly_photo_path(missing_case)
    select 'Mugshot', from: 'avatar_kind'
    click_button 'Update photo type'

    expect(page).to have_content('Marked the current photo as mugshot')
    expect(missing_case.reload).to be_mugshot
  end

  scenario 'an editor rejects a candidate and cannot apply a mugshot' do
    friendly = create(:photo_candidate, case: missing_case, title: 'Family portrait')
    create(:photo_candidate, case: missing_case, title: 'Booking photo',
                             image_url: 'https://upload.wikimedia.org/wikipedia/commons/b/bc/e2e-booking.jpg',
                             likely_mugshot: true)

    sign_in user
    visit friendly_photo_path(missing_case)

    expect(page).to have_css('[data-testid="mugshot-flag"]')
    expect(page).to have_button('Use this photo', count: 1)

    within("[data-testid='candidate-#{friendly.id}']") do
      click_button 'Reject'
    end

    expect(page).to have_content('Rejected that candidate')
    expect(friendly.reload).to be_rejected
    expect(page).not_to have_button('Use this photo')
  end

  scenario 'an editor applies a friendly candidate' do
    allow(FriendlyPhotos::WikimediaClient).to receive(:stubbed?).and_return(true)
    friendly = create(:photo_candidate, case: missing_case, title: 'Family portrait')

    sign_in user
    visit friendly_photo_path(missing_case)
    click_button 'Use this photo'

    expect(page).to have_content('Applied the selected portrait')
    expect(missing_case.reload).to be_portrait
    expect(friendly.reload).to be_accepted
  end

  scenario 'searching stores stubbed Wikimedia hits' do
    sign_in user
    allow(FriendlyPhotos::CandidateSearch).to receive(:call) do |this_case:|
      create(:photo_candidate, case: this_case, title: 'Stubbed portrait')
      this_case.photo_candidates
    end

    visit friendly_photo_path(missing_case)
    click_button 'Search Wikimedia for a friendly photo'

    expect(page).to have_content('Found 1 images')
    expect(page).to have_content('Stubbed portrait')
  end
end
