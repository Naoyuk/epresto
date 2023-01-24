# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe OrderBuilder, type: :model do
  describe 'OrderBuilder#create_order_and_order_items' do
    before do
        vendor = create(:vendor)
        purchase_orders_raw = file_fixture('purchase_orders.json').read
        purchase_orders = JSON.parse(purchase_orders_raw)
        @params = { purchase_orders:, vendor_id: vendor.id }
        @order_records = Order.all.count
        @item_records = OrderItem.all.count
        @order_builder = OrderBuilder.new
    end

    context '必要な値が揃っている場合' do
      it 'Orderのレコードを作成する' do
        create(:shipto, location_code: 'ABCD')
        response = @order_builder.create_order_and_order_items(@params)
        expect(Order.all.count).to eq @order_records + 1
        expect(OrderItem.all.count).to eq @item_records + 1
        expect(response).to eq ({
          :errors => [],
          :po_numbers => [ "L8266355" ]
        })
      end
    end

    context '関連する親のShiptoのレコードが存在しない場合' do
      it 'エラーコード010を返してOrderのレコードの作成に失敗する' do
        create(:shipto, location_code: 'XXXX')
        response = @order_builder.create_order_and_order_items(@params)
        error_res = {
          :errors => [
            {
              :code => '010',
              :desc => 'Import Purchase Order Error',
              :messages =>['Shipto must exist']
            },
            {
              :code=>"020",
              :desc=>"Import Order Item Error",
              :messages=>["Order must exist"]
            }
          ],
          :po_numbers => []
        }
        expect(Order.all.count).to eq @order_records
        expect(OrderItem.all.count).to eq @item_records
        expect(response).to eq error_res
      end
    end

    context '関連する親のVendorのレコードが存在しない場合' do
      it 'エラーコード010を返してOrderのレコードの作成に失敗する' do
        create(:shipto, location_code: 'ABCD')
        @params[:vendor_id] = ''
        response = @order_builder.create_order_and_order_items(@params)
        error_res = {
          :errors => [
            {
              :code => '010',
              :desc => 'Import Purchase Order Error',
              :messages =>['Vendor must exist']
            },
            {
              :code=>"020",
              :desc=>"Import Order Item Error",
              :messages=>["Order must exist"]
            }
          ],
          :po_numbers => []
        }
        expect(Order.all.count).to eq @order_records
        expect(OrderItem.all.count).to eq @item_records
        expect(response).to eq error_res
      end
    end
  end
end
