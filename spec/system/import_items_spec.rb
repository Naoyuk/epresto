# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ImportItems', type: :system do
  before do
    driven_by(:rack_test)
  end

  scenario 'Itemマスターをインポートする対象のファイルを選択しなかった場合はアラートが表示される' do
    # adminユーザーの作成
    create(:vendor)
    user = create(:user, sysadmin: true)

    # adminユーザーでログイン
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    # ファイルを選択せずにUploadボタンを押下
    click_link 'Item Master'
    click_on 'Upload'

    expect(page).to have_content 'Please select a file before uploading.'
  end

  scenario 'adminユーザーはログインしてItemマスターを更新インポートすることができる' do
    # adminユーザーの作成
    create(:vendor)
    user = create(:user, sysadmin: true)

    # adminユーザーでログイン
    visit root_path
    click_link 'Sign in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    # Catalog.xlsxをアップロード
    click_link 'Item Master'
    file_path = Rails.root.join('spec', 'fixtures', 'Catalog.xlsx')
    attach_file('file', file_path)
    click_on 'Upload'

    # 最後のItemレコードのインデックスを取得
    index_last = Item.all.count - 1

    # インポートしたデータが反映されているか、いくつかのレコードをサンプリングして確認
    expect(page.all('.asin')[0]).to have_content 'B0SSSSSSM1'
    expect(page.all('.model-number')[0]).to have_content 'ZZZ02017-Unit'
    expect(page.all('.item-code')[0]).to have_content 'ZZZ02017'
    expect(page.all('.gtin')[0]).to have_content '83293803537012'
    expect(page.all('.external-product-id')[0]).to have_content '83293803537012'
    expect(page.all('.external-product-id-type')[0]).to have_content 'GTIN'

    expect(page.all('.asin')[1]).to have_content 'B0SSSSSSMD'
    expect(page.all('.model-number')[1]).to have_content 'ZZZ02017-CASE'
    expect(page.all('.item-code')[1]).to have_content 'ZZZ02017'
    expect(page.all('.upc')[1]).to have_content '832938035370'
    expect(page.all('.external-product-id')[1]).to have_content '832938035370'
    expect(page.all('.external-product-id-type')[1]).to have_content 'UPC'

    expect(page.all('.asin')[2]).to have_content 'B0UUUUUUFB'
    expect(page.all('.model-number')[2]).to have_content 'GGG00039'
    expect(page.all('.item-code')[2]).to have_content 'GGG00039'
    expect(page.all('.upc')[2]).to have_content '844147004345'
    expect(page.all('.external-product-id')[2]).to have_content '844147004345'
    expect(page.all('.external-product-id-type')[2]).to have_content 'UPC'

    expect(page.all('.asin')[3]).to have_content 'B0FFFFFFG4'
    expect(page.all('.model-number')[3]).to have_content 'FFF00006-CASE'
    expect(page.all('.item-code')[3]).to have_content 'FFF00006'
    expect(page.all('.gtin')[3]).to have_content '82162382022512'
    expect(page.all('.external-product-id')[3]).to have_content '82162382022512'
    expect(page.all('.external-product-id-type')[3]).to have_content 'GTIN'

    expect(page.all('.asin')[4]).to have_content 'B0FFFFFFG3'
    expect(page.all('.model-number')[4]).to have_content 'FFF00006-Unit'
    expect(page.all('.item-code')[4]).to have_content 'FFF00006'
    expect(page.all('.ean')[4]).to have_content '8216238202251'
    expect(page.all('.external-product-id')[4]).to have_content '8216238202251'
    expect(page.all('.external-product-id-type')[4]).to have_content 'EAN'

    expect(page.all('.asin')[9]).to have_content 'B0BBBBBBZ1'
    expect(page.all('.model-number')[9]).to have_content 'BBB00002-Unit'
    expect(page.all('.item-code')[9]).to have_content 'BBB00002'
    expect(page.all('.upc')[9]).to have_content '108950790219'
    expect(page.all('.external-product-id')[9]).to have_content '108950790219'
    expect(page.all('.external-product-id-type')[9]).to have_content 'UPC'

    expect(page.all('.asin')[10]).to have_content 'B0BBBBBBZC'
    expect(page.all('.model-number')[10]).to have_content 'BBB00002-CASE'
    expect(page.all('.item-code')[10]).to have_content 'BBB00002'
    expect(page.all('.gtin')[10]).to have_content '10895079021941'
    expect(page.all('.external-product-id')[10]).to have_content '10895079021941'
    expect(page.all('.external-product-id-type')[10]).to have_content 'GTIN'

    expect(page.all('.asin')[index_last]).to have_content 'B0AAAAAAWX'
    expect(page.all('.model-number')[index_last]).to have_content 'AAA00001-Unit'
    expect(page.all('.item-code')[index_last]).to have_content 'AAA00001'
    expect(page.all('.upc')[index_last]).to have_content '815094021444'
    expect(page.all('.external-product-id')[index_last]).to have_content '815094021444'
    expect(page.all('.external-product-id-type')[index_last]).to have_content 'UPC'

    # Itemマスタのレコード総数をカウント
    records_amount = Item.all.count

    # CCWのマスタファイルをアップロード
    file_path = Rails.root.join('spec', 'fixtures', 'qryGREG_Amazon_ItemInfo.xlsx')
    attach_file('file', file_path)
    click_on 'Upload'

    # 最後のItemレコードのインデックスを取得
    index_last = Item.all.count - 1

    # インポートしたデータの更新が反映されているか、いくつかのレコードをサンプリングして確認
    expect(page.all('.asin')[0]).to have_content 'B0SSSSSSM1'
    expect(page.all('.model-number')[0]).to have_content 'ZZZ02017-Unit'
    expect(page.all('.item-code')[0]).to have_content 'ZZZ02017'
    expect(page.all('.gtin')[0]).to have_content '83293803537012'
    expect(page.all('.external-product-id')[0]).to have_content '83293803537012'
    expect(page.all('.external-product-id-type')[0]).to have_content 'GTIN'
    expect(page.all('.title')[0]).to have_content 'Sample, 6 Count of 500g'

    expect(page.all('.asin')[1]).to have_content 'B0SSSSSSMD'
    expect(page.all('.model-number')[1]).to have_content 'ZZZ02017-CASE'
    expect(page.all('.item-code')[1]).to have_content 'ZZZ02017'
    expect(page.all('.upc')[1]).to have_content '832938035370'
    expect(page.all('.external-product-id')[1]).to have_content '832938035370'
    expect(page.all('.external-product-id-type')[1]).to have_content 'UPC'
    expect(page.all('.title')[1]).to have_content 'Sample, 6 Count of 500g'

    expect(page.all('.asin')[2]).to have_content 'B0UUUUUUFB'
    expect(page.all('.model-number')[2]).to have_content 'GGG00039'
    expect(page.all('.item-code')[2]).to have_content 'GGG00039'
    expect(page.all('.upc')[2]).to have_content '844147004345'
    expect(page.all('.external-product-id')[2]).to have_content '844147004345'
    expect(page.all('.external-product-id-type')[2]).to have_content 'UPC'
    expect(page.all('.title')[2]).to have_content 'Sample 1 count'

    expect(page.all('.asin')[3]).to have_content 'B0FFFFFFG4'
    expect(page.all('.model-number')[3]).to have_content 'FFF00006-CASE'
    expect(page.all('.item-code')[3]).to have_content 'FFF00006'
    expect(page.all('.gtin')[3]).to have_content '82162382022512'
    expect(page.all('.external-product-id')[3]).to have_content '82162382022512'
    expect(page.all('.external-product-id-type')[3]).to have_content 'GTIN'
    expect(page.all('.title')[3]).to have_content 'CDE, YYY Dressing, 200ml (Pack of 1)'

    expect(page.all('.asin')[4]).to have_content 'B0FFFFFFG3'
    expect(page.all('.model-number')[4]).to have_content 'FFF00006-Unit'
    expect(page.all('.item-code')[4]).to have_content 'FFF00006'
    expect(page.all('.ean')[4]).to have_content '8216238202251'
    expect(page.all('.external-product-id')[4]).to have_content '8216238202251'
    expect(page.all('.external-product-id-type')[4]).to have_content 'EAN'
    expect(page.all('.title')[4]).to have_content 'CDE, YYY Dressing, 200ml (Pack of 1)'

    expect(page.all('.asin')[9]).to have_content 'B0BBBBBBZ1'
    expect(page.all('.model-number')[9]).to have_content 'BBB00002-Unit'
    expect(page.all('.item-code')[9]).to have_content 'BBB00002'
    expect(page.all('.upc')[9]).to have_content '108950790219'
    expect(page.all('.external-product-id')[9]).to have_content '108950790219'
    expect(page.all('.external-product-id-type')[9]).to have_content 'UPC'
    expect(page.all('.title')[9]).to have_content 'ABC Foods, XXX Dressing, 6 Count of 237ml'

    expect(page.all('.asin')[10]).to have_content 'B0BBBBBBZC'
    expect(page.all('.model-number')[10]).to have_content 'BBB00002-CASE'
    expect(page.all('.item-code')[10]).to have_content 'BBB00002'
    expect(page.all('.gtin')[10]).to have_content '10895079021941'
    expect(page.all('.external-product-id')[10]).to have_content '10895079021941'
    expect(page.all('.external-product-id-type')[10]).to have_content 'GTIN'
    expect(page.all('.title')[10]).to have_content 'ABC Foods, XXX Dressing, 6 Count of 237ml'

    expect(page.all('.asin')[index_last]).to have_content 'B0AAAAAAWX'
    expect(page.all('.model-number')[index_last]).to have_content 'AAA00001-Unit'
    expect(page.all('.item-code')[index_last]).to have_content 'AAA00001'
    expect(page.all('.upc')[index_last]).to have_content '815094021444'
    expect(page.all('.external-product-id')[index_last]).to have_content '815094021444'
    expect(page.all('.external-product-id-type')[index_last]).to have_content 'UPC'
    expect(page.all('.title')[index_last]).to have_content ''

    # Catalogファイルに無いItemはインポートされていないことを確認
    expect(page.all('.item-code')).not_to have_content 'XXXXXXXX'
    expect(page.all('.title')).not_to have_content 'Sample XXXXX'
    expect(Item.all.count).to eq records_amount
  end
end
