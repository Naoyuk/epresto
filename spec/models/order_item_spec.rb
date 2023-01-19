# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'Case Quantity' do
    context 'when order_item is case order' do
      it 'case quantity return the number that ordered_quantity_amount' do
        item_each = create(:item, pack: 4, case: false)
        order = create(:order)
        order_item_each = create(:order_item,
                                 order_id: order.id,
                                 amazon_product_identifier: item_each.asin,
                                 ordered_quantity_amount: 32)
        order_item_each.convert_case_quantity
        order_item_each.save
        order_item_each.reload

        expect(order_item_each.case_quantity).to eq 8
      end
    end

    context 'when order_item is each order' do
      it 'case quantity return the number that ordered_quantity_amount devided by pack size' do
        item_case = create(:item, pack: 4, case: true)
        order = create(:order)
        order_item_case = create(:order_item,
                                 order_id: order.id,
                                 amazon_product_identifier: item_case.asin,
                                 ordered_quantity_amount: 32)
        order_item_case.convert_case_quantity
        order_item_case.save
        order_item_case.reload

        expect(order_item_case.case_quantity).to eq 32
      end
    end

    context 'when order_item is neither each order or case order' do
      it 'case quantity return nil' do
        item_case_undefined = create(:item, pack: 4, case: nil)
        order = create(:order)
        order_item_case_undefined = create(:order_item,
                                           order_id: order.id,
                                           amazon_product_identifier: item_case_undefined.asin,
                                           ordered_quantity_amount: 32)
        order_item_case_undefined.convert_case_quantity
        order_item_case_undefined.save
        order_item_case_undefined.reload

        expect(order_item_case_undefined.case_quantity).to eq nil
      end
    end
  end
end
