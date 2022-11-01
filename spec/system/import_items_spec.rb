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

    expect(page.all(".item-code")[0]).to have_content 'ANI40002'
    expect(page.all(".pack")[0]).to have_content '6'
    expect(page.all(".item-code")[1]).to have_content 'ANI40001'
    expect(page.all(".pack")[1]).to have_content '12'
    expect(page.all(".item-code")[2]).to have_content 'ANI40000'
    expect(page.all(".pack")[2]).to have_content '1'
    expect(page.all(".stock")[2]).to have_content '0'
    expect(page.all(".item-code")[7]).to have_content 'ANI12020'
    expect(page.all(".z-price")[7]).to have_content '21.28'

    file_path = Rails.root.join('spec', 'fixtures', 'item2.xlsx')
    attach_file('file', file_path)
    click_on 'Upload'

    expect(page.all(".item-code")[0]).to have_content 'ANI40002'
    expect(page.all(".pack")[0]).to have_content '100'
    expect(page.all(".item-code")[1]).to have_content 'ANI40001'
    expect(page.all(".pack")[1]).to have_content '200'
    expect(page.all(".item-code")[2]).to have_content 'ANI40000'
    expect(page.all(".pack")[2]).to have_content '100'
    expect(page.all(".stock")[2]).to have_content '1'
    expect(page.all(".item-code")[7]).to have_content 'ANI12020'
    expect(page.all(".z-price")[7]).to have_content '100.12'
  end
end
