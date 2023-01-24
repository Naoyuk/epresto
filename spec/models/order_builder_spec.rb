# frozen_string_literal: true

require 'rails_helper'
require 'json'

RSpec.describe OrderBuilder, type: :model do
  describe 'OrderBuilder#create_order_and_order_items' do
    context '必要な値が揃っている場合' do
      it 'Orderのレコードを作成する' do
        vendor = create(:vendor)
        create(:shipto, location_code: 'ABCD')
        purchase_orders_raw = file_fixture('purchase_orders.json').read
        purchase_orders = JSON.parse(purchase_orders_raw)
        params = { purchase_orders:, vendor_id: vendor.id }
        records = Order.all.count
        order_builder = OrderBuilder.new

        response = order_builder.create_order_and_order_items(params)
        expect(Order.all.count).to eq records + 1
        expect(response).to eq ({
          :errors => [],
          :po_numbers => [ "L8266355" ]
        })
      end
    end

    context '関連する親のShiptoのレコードが存在しない場合' do
      it 'エラーコード010を返してOrderのレコードの作成に失敗する' do
        vendor = create(:vendor)
        create(:shipto, location_code: 'XXXX')
        purchase_orders_raw = file_fixture('purchase_orders.json').read
        purchase_orders = JSON.parse(purchase_orders_raw)
        params = { purchase_orders:, vendor_id: vendor.id }
        records = Order.all.count
        order_builder = OrderBuilder.new

        response = order_builder.create_order_and_order_items(params)
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
        expect(Order.all.count).to eq records
        expect(response).to eq error_res
      end
    end

    context '関連する親のVendorのレコードが存在しない場合' do
      it 'エラーコード010を返してOrderのレコードの作成に失敗する' do
        create(:shipto, location_code: 'ABCD')
        purchase_orders_raw = file_fixture('purchase_orders.json').read
        purchase_orders = JSON.parse(purchase_orders_raw)
        params = { purchase_orders:, vendor_id: '' }
        records = Order.all.count
        order_builder = OrderBuilder.new

        response = order_builder.create_order_and_order_items(params)
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
        expect(Order.all.count).to eq records
        expect(response).to eq error_res
      end
    end
  end
end
