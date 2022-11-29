# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item, type: :model do
  it 'has a valid factory' do
    expect(build(:item)).to be_valid
  end

  it 'is invalid without item_code' do
    item = build(:item, item_code: nil)
    expect(item).not_to be_valid
    expect(item.errors[:item_code]).to include("can't be blank")
  end

  it 'is invalid without upc' do
    item = build(:item, upc: nil)
    expect(item).not_to be_valid
    expect(item.errors[:upc]).to include("can't be blank")
  end

  it 'is invalid without ASIN' do
    item = build(:item, asin: nil)
    expect(item).not_to be_valid
    expect(item.errors[:asin]).to include("can't be blank")
  end

  describe 'case or each' do
    before do
      @item_case = create(:item, case: true)
      @item_each = create(:item, case: false)
    end

    context 'case is true' do
      it 'Case? method returns true' do
        expect(@item_case.Case?).to eq true
      end
      it 'Each? method returns false' do
        expect(@item_case.Each?).to eq false
      end
    end

    context 'case is false' do
      it 'Case? method returns false' do
        expect(@item_each.Case?).to eq false
      end
      it 'Each? method returns true' do
        expect(@item_each.Each?).to eq true
      end
    end
  end
end
