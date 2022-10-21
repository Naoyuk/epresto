# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RegisterNewUsers', type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario 'an admin user can create a new user' do
    admin_user = create(:sysadmin)

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: admin_user.email
    fill_in 'Password', with: admin_user.password
    click_button 'Log in'
    visit profile_path

    expect {
      click_link 'Register a new user'
      fill_in 'Name', with: 'new user'
      fill_in 'Email', with: 'newemail@example.com'
      fill_in 'Password', with: 'password'
      fill_in 'Password confirmation', with: 'password'
      click_button 'Register'

      visit users_path
      expect(page).to have_content 'new user'
      expect(page).to have_content 'newemail@example.com'
      visit profile_path
      expect(page).to have_content admin_user.name
      expect(page).to have_content admin_user.email
    }.to change(User, :count).by(1)
  end

  scenario 'a normal user can not see a register new user button' do
    user = create(:user)

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    visit profile_path

    expect(page).not_to have_content 'Register a new user'
  end
end
