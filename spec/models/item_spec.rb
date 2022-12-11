# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item, type: :model do
  it 'has a valid factory' do
    expect(build(:item)).to be_valid
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
