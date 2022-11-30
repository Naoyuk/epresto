# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ImportItems', type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario 'An admin-user log in and import and update item master' do
    create(:vendor)
    user = create(:user, sysadmin: true)

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    click_link 'Item Master'
    file_path = Rails.root.join('spec', 'fixtures', 'item1.xlsx')
    attach_file('file', file_path)
    click_on 'Upload'

    expect(page.all('.item-code')[0]).to have_content 'ANI40002'
    expect(page.all('.pack')[0]).to have_content '6'
    expect(page.all('.item-code')[1]).to have_content 'ANI40001'
    expect(page.all('.pack')[1]).to have_content '12'
    expect(page.all('.item-code')[2]).to have_content 'ANI40000'
    expect(page.all('.pack')[2]).to have_content '1'
    expect(page.all('.item-code')[7]).to have_content 'ANI12020'
    expect(page.all('.z-price')[7]).to have_content '21.28'

    # For checking to be updated or passed
    before_updated_at10001 = Item.find_by(item_code: 'ANI10001').updated_at
    before_updated_at10120 = Item.find_by(item_code: 'ANI10120').updated_at
    before_updated_at11300 = Item.find_by(item_code: 'ANI11300').updated_at
    before_updated_at12005 = Item.find_by(item_code: 'ANI12005').updated_at
    before_updated_at40001 = Item.find_by(item_code: 'ANI40001').updated_at
    before_updated_at40002 = Item.find_by(item_code: 'ANI40002').updated_at

    file_path = Rails.root.join('spec', 'fixtures', 'item2.xlsx')
    attach_file('file', file_path)
    click_on 'Upload'

    expect(page.all('.item-code')[0]).to have_content 'ANI40002'
    expect(page.all('.pack')[0]).to have_content '100'
    expect(page.all('.item-code')[1]).to have_content 'ANI40001'
    expect(page.all('.pack')[1]).to have_content '12'
    expect(page.all('.item-code')[2]).to have_content 'ANI40000'
    expect(page.all('.pack')[2]).to have_content '100'
    expect(page.all('.item-code')[7]).to have_content 'ANI12020'
    expect(page.all('.z-price')[7]).to have_content '100.12'
    after_updated_at10001 = Item.find_by(item_code: 'ANI10001').updated_at
    after_updated_at10120 = Item.find_by(item_code: 'ANI10120').updated_at
    after_updated_at11300 = Item.find_by(item_code: 'ANI11300').updated_at
    after_updated_at12005 = Item.find_by(item_code: 'ANI12005').updated_at
    after_updated_at40001 = Item.find_by(item_code: 'ANI40001').updated_at
    after_updated_at40002 = Item.find_by(item_code: 'ANI40002').updated_at
    expect(before_updated_at10001).to eq after_updated_at10001
    expect(before_updated_at10120).not_to eq after_updated_at10120
    expect(before_updated_at11300).to eq after_updated_at11300
    expect(before_updated_at12005).not_to eq after_updated_at12005
    expect(before_updated_at40001).to eq after_updated_at40001
    expect(before_updated_at40002).not_to eq after_updated_at40002
  end
end
