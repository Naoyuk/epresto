# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ImportItems', type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario 'A user log in and import and update item master' do
    vendor = create(:vendor)
    user = create(:user)

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    click_link 'Item Info'
    file_path = Rails.root.join('spec', 'fixtures', 'item1.xlsx')
    attach_file('file', file_path)
    click_on 'Upload'

    expect(page).to have_content 'ANI10001'
  end
end
