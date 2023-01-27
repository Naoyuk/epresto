# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  it 'has a valid factory' do
    expect(build(:order)).to be_valid
  end

  # describe 'GET get_purchase_orders' do
  #   context 'when valid params are given' do
  #     it 'returns 200 response' do
  #       params = {
  #         api: 'pos',
  #         path: '/vendor/orders/v1/purchaseOrders',
  #         created_after: Time.now - 7 * 24 * 3600,
  #         created_before: Time.now
  #       }
  #       res = Order.get_purchase_orders(params)
  #       expect(res.code).to eq '200'
  #     end
  #   end

  #   context 'when invalid params are given' do
  #     it 'does not return 200 response' do
  #       params = {
  #         api: 'pos',
  #         path: '/vendor/orders/v1/purchaseOrd',
  #         created_after: Time.now - 7 * 24 * 3600,
  #         created_before: Time.now
  #       }
  #       res = Order.get_purchase_orders(params)
  #       expect(res.code).not_to eq '200'
  #       expect(res.code).to eq '403'
  #     end
  #   end
  # end
end
