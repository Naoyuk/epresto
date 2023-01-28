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

      # SP-APIのgetPurchaseOrdersのJSONパース済response.bodyを取得
      purchase_orders = amazon_api.get_purchase_orders(created_after, created_before)
      orders = purchase_orders['payload']['orders']

      # なんらかのエラーでPOを取得できなかったらエラーコードをviewに渡して終了
      return purchase_orders if purchase_orders.has_key?('errors')

      # purchase_ordersからOrderとOrderItemにレコードを作成していく
      order_builder = OrderBuilder.new

      # Orderと、それに紐づくOrderItemの作成
      orders.each do |order_params|
        po_numbers = []
        errors = []

        # Orderの作成
        # order_builder.build_orderは検索or新規して各値をセットしたOrderオブジェクトを返す
        order = order_builder.build_order(order_params, vendor_id)
        # TODO: 例外の処理が合ってるか確認
        begin
          order.save
          po_numbers << order.po_number
        rescue
          errors << STDERR
          #   error = {
          #   TODO: エラー情報は仮
          #     code: '010',
          #     desc: 'Import Purchase Order Error',
          #     messages: odr.errors.full_messages
          #   }
        end

        # OrderItemの作成
        order_items = orders['orderDetais']['items']

        order_items.each do |order_item_params|
          order_item = order_builder.build_order_item(order_item_params)
          if order_item.valid?
            order_item.save
            po_numbers << order.po_number
          else
            errors << STDERR
            #   error = {
            #   TODO: エラー情報は仮
            #     code: '020',
            #     desc: 'Import Order Item Error',
            #     messages: itm.errors.full_messages
            #   }
          end
        end
      end

      orders = Order.where(po_number: po_numbers)
      { orders:, errors: }
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
