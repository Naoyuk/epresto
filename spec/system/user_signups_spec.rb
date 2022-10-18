require 'rails_helper'

RSpec.describe "UserSignups", type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario 'a guest sign up successfully with valid email, password and password confirmation' do
    visit root_path
    first(:link, 'Sign up').click
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'
    click_button 'Sign up'

    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

  scenario 'a guest failed to sign up without email' do
    visit root_path
    first(:link, 'Sign up').click
    fill_in 'Email', with: nil
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'
    click_button 'Sign up'

    expect(page).to have_content "Email can't be blank"
  end

  scenario 'a guest failed to sign up with duplicated email' do
    user = create(:user)

    visit root_path
    first(:link, 'Sign up').click
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'
    click_button 'Sign up'

    expect(page).to have_content "Email has already been taken"
  end

  scenario 'a guest failed to sign up without password' do
    visit root_path
    first(:link, 'Sign up').click
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: nil 
    fill_in 'Password confirmation', with: 'password'
    click_button 'Sign up'

    expect(page).to have_content "Password can't be blank"
  end

  scenario 'a guest failed to sign up without password confirmation' do
    visit root_path
    first(:link, 'Sign up').click
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: nil
    click_button 'Sign up'

    expect(page).to have_content "Password confirmation doesn't match Password"
  end

  scenario 'a guest failed to sign up if a password and password confirmation are different' do
    visit root_path
    first(:link, 'Sign up').click
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'foo'
    click_button 'Sign up'

    expect(page).to have_content "Password confirmation doesn't match Password"
  end
end
