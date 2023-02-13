# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe OrderBuilder, type: :model do
  describe '#build_order' do
    before do
      purchase_orders_raw = file_fixture('purchase_orders.json').read
      purchase_orders = JSON.parse(purchase_orders_raw)
      @order = purchase_orders['payload']['orders'][0]
      @vendor = create(:vendor)
    end

    context '必要な値が揃っている場合' do
      it 'Orderのレコードを作成する' do
        create(:shipto, location_code: 'ABCD')
        order_builder = OrderBuilder.new
        expect {
          order_builder.build_order(@order, @vendor.id)
        }.to change(Order, :count).by(1)
      end
    end

    context '関連する親のShiptoのレコードが存在しない場合' do
      it 'Orderのレコードの作成に失敗する' do
        create(:shipto, location_code: 'XXXX')
        order_builder = OrderBuilder.new
        expect {
          order_builder.build_order(@order, @vendor.id)
        }.to change(Order, :count).by(0)
      end
    end

    context '関連する親のVendorのレコードが存在しない場合' do
      it 'Orderのレコードの作成に失敗する' do
        create(:shipto, location_code: 'ABCD')
        order_builder = OrderBuilder.new
        expect {
          order_builder.build_order(@order, nil)
        }.to change(Order, :count).by(0)
      end
    end
  end

  # describe '#build_order_item' do
  #   let(:order) { create(:order) }

  #   before do
  #     purchase_orders_raw = file_fixture('purchase_orders.json').read
  #     purchase_orders = JSON.parse(purchase_orders_raw)
  #     @params = purchase_orders['payload']['orders'][0]['orderDetails']['items'][0]
  #   end

  #   context '必要な値が揃っている場合' do
  #     it 'OrderItemのレコードの作成に成功する' do
  #       order = create(:order)
  #       order_builder = OrderBuilder.new
  #       order_item = order_builder.build_order_item(@params, order.id)
  #       expect(order_item).to be_valid
  #     end
  #   end

  #   context 'order_idが引数として与えられていない場合' do
  #     it 'OrderItemのレコードの作成に失敗する' do
  #       order_builder = OrderBuilder.new
  #       order_item = order_builder.build_order_item(@params, nil)
  #       order_item.valid?

  #       expect(order_item.errors.full_messages).to include('Order must exist')
  #     end
  #   end
  # end
end
