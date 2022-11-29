# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'Case Quantity' do
    before do
      item_each = create(:item, pack: 4, case: false)
      item_case = create(:item, pack: 4, case: true)
      order = create(:order)
      @order_item_each = create(
        :order_item,
        order_id: order.id,
        item_id: item_each.id,
        ordered_quantity_amount: 32
      )
      @order_item_case = create(
        :order_item,
        order_id: order.id,
        item_id: item_case.id,
        ordered_quantity_amount: 32
      )
    end

    context 'when order_item is case order' do
      it 'case quantity return the number that ordered_quantity_amount' do
        @order_item_each.convert_case_quantity
        @order_item_each.reload
        expect(@order_item_each.case_quantity).to eq 8
      end
    end

    context 'when order_item is each order' do
      it 'case quantity return the number that ordered_quantity_amount devided by pack size' do
        @order_item_case.convert_case_quantity
        @order_item_case.reload
        expect(@order_item_case.case_quantity).to eq 32
      end
    end
  end
end
