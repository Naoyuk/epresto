# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item, type: :model do
  it 'has a valid factory' do
    expect(build(:item)).to be_valid
  end

  describe 'case or each' do
    context 'case is true' do
      it 'Case? method returns true' do
        item_case = create(:item, case: true)
        expect(item_case.Case?).to eq true
      end
      it 'Each? method returns false' do
        item_case = create(:item, case: true)
        expect(item_case.Each?).to eq false
      end
    end

    context 'case is false' do
      it 'Case? method returns false' do
        item_each = create(:item, case: false)
        expect(item_each.Case?).to eq false
      end
      it 'Each? method returns true' do
        item_each = create(:item, case: false)
        expect(item_each.Each?).to eq true
      end
    end
  end

  describe 'Item#cols_access' do
    it 'Access_item.xlsxの取り込みシートのカラムとItemマスタのカラムの対応をハッシュで返す' do
      file_path = Rails.root.join('spec', 'fixtures', 'Access_item.xlsx')
      xls = Roo::Excelx.new(file_path)
      sheet_obj = xls.sheet(xls.sheets[0])
      cols_xls = sheet_obj.row(1)
      cols = Item.cols_access(cols_xls)
      result = {
        "I_ITEM_CODE"=>"item_code",
        "I_UPC"=>"upc",
        "I_ITEM"=>"title",
        "I_BRAND"=>"brand",
        "I_SIZE"=>"size",
        "I_PACK"=>"pack",
        "I_WHOLESALE"=>"price",
        "I_Z_PRICING"=>"z_pricing",
        "I_STOCK"=>"stock",
        "I_DEPT"=>"dept",
        "I_STATUS"=>"status",
        "I_VENDOR"=>"vendor",
        "IM_CASE_UPC"=>"external_product_id"
      }
      expect(cols).to eq result
    end
  end

  describe 'Item#cols_catalog' do
    it 'Catalog.xlsxの取り込みシートのカラムとItemマスタのカラムの対応をハッシュで返す' do
      file_path = Rails.root.join('spec', 'fixtures', 'Catalog.xlsx')
      xls = Roo::Excelx.new(file_path)
      sheet_obj = xls.sheet('Template-SALAD_DRESSING')
      cols_xls = sheet_obj.row(3)
      cols = Item.cols_catalog(cols_xls)
      result = {
        "Vendor Code"=>"vendor_code",
        "Vendor SKU"=>"vendor_sku",
        "Product Type"=>"product_type",
        "Item Name"=>"item_name",
        "Brand Name"=>"brand_name",
        "External Product ID"=>"external_product_id",
        "External Product ID Type"=>"external_product_id_type",
        "Merchant Suggested Asin"=>"merchant_suggested_asin",
        "Size"=>"size"
      }
      expect(cols).to eq result
    end
  end

  describe 'Item#check_digit' do
    context '11桁の数値を渡した場合' do
      it 'Check Digitを末尾に追加した12桁のUPCを返す' do
        value11 = '01234567890'
        upc = value11 + Item.check_digit(value11)
        expect(upc).to eq '012345678905'

        value11 = '11234567890'
        upc = value11 + Item.check_digit(value11)
        expect(upc).to eq '112345678902'

        value11 = '11234867890'
        upc = value11 + Item.check_digit(value11)
        expect(upc).to eq '112348678909'
      end
    end

    context '12桁の数値を渡した場合' do
      it 'Check Digitを末尾に追加した13桁のEANを返す' do
        value12 = '012345678901'
        upc = value12 + Item.check_digit(value12)
        expect(upc).to eq '0123456789012'

        value12 = '112345678901'
        upc = value12 + Item.check_digit(value12)
        expect(upc).to eq '1123456789011'

        value12 = '112348678901'
        upc = value12 + Item.check_digit(value12)
        expect(upc).to eq '1123486789012'
      end
    end

    context '13桁の数値を渡した場合' do
      it 'Check Digitを末尾に追加した14桁のGTINを返す' do
        value13 = '0123456789012'
        upc = value13 + Item.check_digit(value13)
        expect(upc).to eq '01234567890128'

        value13 = '1123456789012'
        upc = value13 + Item.check_digit(value13)
        expect(upc).to eq '11234567890125'

        value13 = '1123486789012'
        upc = value13 + Item.check_digit(value13)
        expect(upc).to eq '11234867890122'
      end
    end
  end
end
