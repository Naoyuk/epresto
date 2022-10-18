# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserSessions', type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario 'user logs in successfully with a valid email and password' do
    user = create(:user)

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    expect(page).to have_content 'Signed in successfully.'
  end

  scenario 'user failed to logs in without an email' do
    user = create(:user)

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: nil
    fill_in 'Password', with: user.password
    click_button 'Log in'

    expect(page).to have_content 'Invalid Email or password'
  end

  scenario 'user failed to logs in with an invalid email' do
    user = create(:user)

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: 'wrongemail@example.com'
    fill_in 'Password', with: user.password
    click_button 'Log in'

    expect(page).to have_content 'Invalid Email or password'
  end

  scenario 'user failed to logs in without a password' do
    user = create(:user)

    visit root_path
    click_link 'Sign in'
    fill_in 'Password', with: user.password
    fill_in 'Password', with: nil
    click_button 'Log in'

    expect(page).to have_content 'Invalid Email or password'
  end

  scenario 'user failed to logs in with an invalid password' do
    user = create(:user)

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'wrongpassword'
    click_button 'Log in'

    expect(page).to have_content 'Invalid Email or password'
  end

  scenario 'user log out' do
    user = create(:user)

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    click_link 'Log out'

    expect(page).to have_content 'Signed out successfully.'
  end
end
