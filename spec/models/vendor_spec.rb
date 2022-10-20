# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vendor, type: :model do
  it 'has a valid factory' do
    expect(build(:vendor)).to be_valid
  end

  it 'is invalid without name' do
    vendor = build(:vendor, name: nil)
    expect(vendor).not_to be_valid
    expect(vendor.errors[:name]).to include("can't be blank")
  end
end
