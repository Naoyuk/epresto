# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Profiles', type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario 'a user see own profile after log in' do
    user = create(:user)

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    visit profile_path

    expect(page).to have_content user.name
    expect(page).to have_content user.email
  end

  scenario "a user don't see own profile before log in" do
    user = create(:user)

    visit profile_path

    expect(page).not_to have_content user.name
    expect(page).not_to have_content user.email
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
