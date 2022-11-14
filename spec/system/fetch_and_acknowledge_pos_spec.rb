require 'rails_helper'

RSpec.describe "FetchAndAcknowledgePos", type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario 'a user get po data from Amazon and update orders and order items', vcr: true do
    vendor = create(:vendor)
    user = create(:user)

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    click_link 'Purchase Order'
    expect(page).not_to have_content 'mock-purchaseOrderNumber1'
    expect(page).not_to have_content 'mock-purchaseOrderNumber2'
    expect(page).not_to have_content 'B01LNRIIAB'
    expect(page).not_to have_content 'B07DFVDRAB'
    click_button 'Update'
    expect(page).to have_content 'mock-purchaseOrderNumber1'
    expect(page).to have_content 'mock-purchaseOrderNumber2'
    expect(page).to have_content 'B01LNRIIAB'
    expect(page).to have_content 'B07DFVDRAB'
  end
end
