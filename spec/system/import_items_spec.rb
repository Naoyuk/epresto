# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ImportItems', type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario 'An admin-user log in and import files and update item master' do
    create(:vendor)
    user = create(:user, sysadmin: true)

    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    click_link 'Item Master'
    file_path = Rails.root.join('spec', 'fixtures', 'Catalog.xlsm')
    attach_file('file', file_path)
    click_on 'Upload'

    index_last = Item.all.count - 1

    expect(page.all('.asin')[0]).to have_content 'B0SSSSSSMD'
    expect(page.all('.model-number')[0]).to have_content 'ZZZ02017-CASE'
    expect(page.all('.upc')[0]).to have_content '832938035370'
    expect(page.all('.external-product-id')[0]).to have_content '832938035370'
    expect(page.all('.external-product-id-type')[0]).to have_content 'UPC'

    expect(page.all('.asin')[1]).to have_content 'B0UUUUUUFB'
    expect(page.all('.model-number')[1]).to have_content 'GGG00039'
    expect(page.all('.upc')[1]).to have_content '844147004345'
    expect(page.all('.external-product-id')[1]).to have_content '844147004345'
    expect(page.all('.external-product-id-type')[1]).to have_content 'UPC'

    expect(page.all('.asin')[2]).to have_content 'B0FFFFFFG3'
    expect(page.all('.model-number')[2]).to have_content 'FFF00006-Unit'
    expect(page.all('.ean')[2]).to have_content '8216238202251'
    expect(page.all('.external-product-id')[2]).to have_content '8216238202251'
    expect(page.all('.external-product-id-type')[2]).to have_content 'EAN'

    expect(page.all('.asin')[6]).to have_content 'B0BBBBBBZC'
    expect(page.all('.model-number')[6]).to have_content 'BBB00002-CASE'
    expect(page.all('.gtin')[6]).to have_content '10895079021941'
    expect(page.all('.external-product-id')[6]).to have_content '10895079021941'
    expect(page.all('.external-product-id-type')[6]).to have_content 'GTIN'

    expect(page.all('.asin')[index_last]).to have_content 'B0AAAAAAWX'
    expect(page.all('.model-number')[index_last]).to have_content 'AAA00001-Unit'
    expect(page.all('.upc')[index_last]).to have_content '815094021444'
    expect(page.all('.external-product-id')[index_last]).to have_content '815094021444'
    expect(page.all('.external-product-id-type')[index_last]).to have_content 'UPC'
    
    records_amount = Item.all.count

    file_path = Rails.root.join('spec', 'fixtures', 'Access_item.xlsx')
    attach_file('file', file_path)
    click_on 'Upload'

    index_last = Item.all.count - 1

    expect(page.all('.asin')[0]).to have_content 'B0SSSSSSMD'
    expect(page.all('.model-number')[0]).to have_content 'ZZZ02017-CASE'
    expect(page.all('.upc')[0]).to have_content '832938035370'
    expect(page.all('.external-product-id')[0]).to have_content '832938035370'
    expect(page.all('.external-product-id-type')[0]).to have_content 'UPC'
    expect(page.all('.item-code')[0]).to have_content 'AAC00217'
    expect(page.all('.title')[0]).to have_content 'Sample, 6 Count of 500g'

    expect(page.all('.asin')[1]).to have_content 'B0UUUUUUFB'
    expect(page.all('.model-number')[1]).to have_content 'GGG00039'
    expect(page.all('.upc')[1]).to have_content '844147004345'
    expect(page.all('.external-product-id')[1]).to have_content '844147004345'
    expect(page.all('.external-product-id-type')[1]).to have_content 'UPC'
    expect(page.all('.item-code')[1]).to have_content 'AAC00216'
    expect(page.all('.title')[1]).to have_content 'Sample 1 count'

    expect(page.all('.asin')[2]).to have_content 'B0FFFFFFG3'
    expect(page.all('.model-number')[2]).to have_content 'FFF00006-Unit'
    expect(page.all('.ean')[2]).to have_content '8216238202251'
    expect(page.all('.external-product-id')[2]).to have_content '8216238202251'
    expect(page.all('.external-product-id-type')[2]).to have_content 'EAN'
    expect(page.all('.item-code')[2]).to have_content 'AAC00213'
    expect(page.all('.title')[2]).to have_content 'CDE, YYY Dressing, 200ml (Pack of 1)'

    expect(page.all('.asin')[6]).to have_content 'B0BBBBBBZC'
    expect(page.all('.model-number')[6]).to have_content 'BBB00002-CASE'
    expect(page.all('.gtin')[6]).to have_content '10895079021941'
    expect(page.all('.external-product-id')[6]).to have_content '10895079021941'
    expect(page.all('.external-product-id-type')[6]).to have_content 'GTIN'
    expect(page.all('.item-code')[6]).to have_content 'AAC00207'
    expect(page.all('.title')[6]).to have_content 'ABC Foods, XXX Dressing, 6 Count of 237ml'

    expect(page.all('.asin')[index_last]).to have_content 'B0AAAAAAWX'
    expect(page.all('.model-number')[index_last]).to have_content 'AAA00001-Unit'
    expect(page.all('.upc')[index_last]).to have_content '815094021444'
    expect(page.all('.external-product-id')[index_last]).to have_content '815094021444'
    expect(page.all('.external-product-id-type')[index_last]).to have_content 'UPC'
    # IM_CASE_UPC != external_product_id のバターン
    expect(page.all('.item-code')[index_last]).to have_content ''
    expect(page.all('.title')[index_last]).to have_content ''

    # Catalogファイルに無いItemはインポートされていない
    expect(page.all('.item-code')).not_to have_content 'XXXXXXXX'
    expect(page.all('.title')).not_to have_content 'Sample XXXXX'
    expect(Item.all.count).to eq records_amount
  end
end
