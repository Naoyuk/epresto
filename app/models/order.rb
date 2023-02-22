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
    def import_purchase_orders(vendor_id, created_after, created_before)
      # AmazonからPurchaseOrdersを取得してOrderテーブルにレコードを更新/追加する

      amazon_api = AmazonAPIClient.new

      # SP-APIのgetPurchaseOrdersのJSONパース済response.bodyを取得
      purchase_orders = amazon_api.get_purchase_orders(created_after, created_before)

      # なんらかのエラーでPOを取得できなかったらエラーコードをviewに渡して終了
      return purchase_orders if purchase_orders.has_key?('errors')

      # purchase_ordersからOrderとOrderItemにレコードを作成していく
      order_params_list = purchase_orders['payload']['orders']

      order_builder = OrderBuilder.new

      # Orderと、それに紐づくOrderItemの作成
      order_params_list.map do |order_params|
        # if order_params['purchaseOrderState'] == 'New'
        # PO StatusがNewの場合のみOrderの作成
        # order_builder.build_orderは検索or新規して各値をセットしたOrderオブジェクトを返す
        # order_builder.build_order(order_params, vendor_id)
        # end

        # PO StateばNewのOrderのみ更新したらStateがAcknowledgedからClosedなどにアップデートされないので、やはり全てを更新する必要がある
        # 一覧で今週のものに絞ってるので、更新は全てに対して行って問題ないはず
        order_builder.build_order(order_params, vendor_id)
      end
    end

    def acknowledge(po_numbers)
      # 対象のPOに対してAcknowledgeする

      # Acknowledge対象のPOを検索
      order_ids = Order.where(po_number: po_numbers.split(' ')).ids
      orders = Order.where(id: order_ids)

      amazon_api = AmazonAPIClient.new

      # HTTPリクエストのbodyのJSONを作る
      req_body = amazon_api.build_acknowledge_request_body(orders)

      # Acknowledgementのデバッグ用のログ
      logger.debug('Acknowledgement Reqest')
      logger.debug(req_body)

      # SP-APIのsubmitAcknowledgementを叩く
      response = amazon_api.submit_acknowledgements(req_body)
      JSON.parse(response.body)

      # @cost_difference_notice
    end
  end
end
