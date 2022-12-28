require 'rails_helper'

RSpec.describe 'Toggle regular and bulk order', type: :system do
  let(:user) { create(:user) }

  before do
    @order1 = create(:order)
    @order2 = create(:order)
    @order3 = create(:order)

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    click_link 'Purchase Order'
    click_link 'Bulk'
  end

  # scenario 'Batch check and convert all checked Orders to Bulk', js: true do
  #   expect(@order1.po_type).to eq 'RegularOrder'
  #   expect(@order2.po_type).to eq 'RegularOrder'
  #   expect(@order3.po_type).to eq 'RegularOrder'

  #   check 'check-all'
  #   click_button 'Convert to Bulk Order'

  #   @order1.reload
  #   @order2.reload
  #   @order3.reload
  #   expect(@order1.po_type).to eq 'BulkOrder'
  #   expect(@order2.po_type).to eq 'BulkOrder'
  #   expect(@order3.po_type).to eq 'BulkOrder'
  # end

  # scenario 'Check individually and convert all checked Orders to Bulk', js: true do
  #   expect(@order1.po_type).to eq 'RegularOrder'
  #   expect(@order2.po_type).to eq 'RegularOrder'
  #   expect(@order3.po_type).to eq 'RegularOrder'

  #   all('.check')[0].check
  #   click_button 'Convert to Bulk Order'

  #   expect(page).to have_content "Bulk Order"
  #   expect(all('tr')[1]).to have_content 'BulkOrder'
  #   expect(all('tr')[2]).to have_content 'RegularOrder'
  #   expect(all('tr')[3]).to have_content 'RegularOrder'
  # end

  # scenario 'Batch check and convert all checked Orders to Regular', js: true do
  # end

  # scenario 'Check individually and convert all checked Orders to Regular', js: true do
  #   expect(@order1.po_type).to eq 'RegularOrder'
  #   expect(@order2.po_type).to eq 'RegularOrder'
  #   expect(@order3.po_type).to eq 'RegularOrder'

  #   all('.check')[1].check
  #   click_button 'Convert to Regular Order'

  #   expect(page).to have_content "Bulk Order"
  #   expect(all('tr')[1]).to have_content 'RegularOrder'
  #   expect(all('tr')[2]).to have_content 'RegularOrder'
  #   expect(all('tr')[3]).to have_content 'RegularOrder'

  #   all('.check')[0].check
  #   click_button 'Convert to Bulk Order'

  #   expect(page).to have_content "Bulk Order"
  #   expect(all('tr')[1]).to have_content 'BulkOrder'
  #   expect(all('tr')[2]).to have_content 'RegularOrder'
  #   expect(all('tr')[3]).to have_content 'RegularOrder'
  # end
end
