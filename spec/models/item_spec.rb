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
end
