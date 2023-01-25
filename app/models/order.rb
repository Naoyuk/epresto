# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :vendor
  belongs_to :shipto
  has_many :order_items

  # definitions of enum
  enum po_state: {
    New: 0,
    Acknowledged: 1,
    Closed: 2
  }

  enum po_type: {
    RegularOrder: 0,
    ConsignedOrder: 1,
    NewProductionIntroduction: 2,
    BulkOrder: 3
  }

  enum payment_method: {
    Invoice: 0,
    Consignment: 1,
    CreditCard: 2,
    Prepaid: 3
  }

  class << self
    def import_po(vendor_id, created_after, created_before)
      # AmazonからPurchaseOrderを取得してOrderテーブルにレコードを更新/追加する

      amazon_api = AmazonAPIClient.new

      # SP-APIのgetPurchaseOrdersのレスポンスを取得
      response = amazon_api.get_purchase_orders(created_after, created_before)
      purchase_orders = JSON.parse(response.body)

      # なんらかのエラーでPOを取得できなかったらエラーコードをviewに渡して終了
      return purchase_orders if purchase_orders.has_key?('errors')

      # purchase_ordersからOrdersとOrderItemsにレコードを作成していく
      order_builder = OrderBuilder.new
      params = { purchase_orders:, vendor_id: }
      response = order_builder.create_order_and_order_items(params)

      # GETしたPOを元に作成したOrderのオブジェクト、またはエラーを返す
      errors = response[:errors]
      { orders: Order.where(po_number: response[:po_numbers].split(' ')).ids, errors: }
    end

    def acknowledge(po_numbers)
      # 対象のPOに対してAcknowledgeする

      # Acknowledge対象のPOを検索
      order_ids = Order.where(po_number: po_numbers.split(' ')).ids
      orders = Order.where(id: order_ids)

      amazon_api = AmazonAPIClient.new

      # HTTPリクエストのbodyのJSONを作る
      req_body = amazon_api.build_acknowledge_request_body(orders)

      # SP-APIのsubmitAcknowledgementを叩く
      response = amazon_api.submit_acknowledgements(req_body)
      JSON.parse(response.body)

      # @cost_difference_notice
    end
  end
end
