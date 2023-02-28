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

  def import_purchase_orders_history(file)
    # Excelファイルで保存していた過去のPurchase Orderの取り込み
    # One time usage
    # インポートファイルの読み込み
    xls = Roo::Excelx.new(file)

    # インポート対象のシートとカラム名を取得
    sheet= xls.sheet(xls.sheets[0])

    # Excelデータを配列に入れる
    order_params = []
    sheet.each(po_number: 'PO', vendor: 'Vendor', po_date: 'Ordered On', location: 'Ship to location',
               window_type: 'Window Type', window_start: 'Window Start', window_end: 'Window End') do |hash|
                 unless hash[:po_number] == 'PO'
                   order = Order.new(
                     po_number: hash[:po_number],
                     po_state: 2,
                     po_date: hash[:po_date],
                   )
                 end
                 location_code = hash[:location].slice(0..3)
                 ship_to = Shipto.find_by_location_code(location_code)
                 order.shipto_id = ship_to.id
                 order.save
               end
  end

  def import_order_items_history(file)
    # Excelファイルで保存していた過去のOrderItemsの取り込み
    # One time usage
    # インポートファイルの読み込み
    xls = Roo::Excelx.new(file)

    # インポート対象のシートとカラム名を取得
    sheet= xls.sheet(xls.sheets[0])

    # Excelデータを配列に入れる
    order_params = []
    sheet.each(po_number: 'PO', vendor: 'Vendor', location: 'Ship to location', asin: 'ASIN',
               external_id: 'External ID', external_id_type: 'External Id Type', model_number: 'Model Number',
               title: 'Title', availability: 'Availability', window_type: 'Window Type', window_start: 'Window Start',
               window_end: 'Window End', expected_date: 'Expected Date', quantity_requested: 'Quantity Requested',
               accepted_quantity: 'Accepted Quantity', quantity_received: 'Quantity received', quantity_outstanding: 'Quantity Outstanding',
               unit_cost: 'Unit Cost') do |hash|
                 unless hash[:po_number] == 'PO'
                   order = Order.find_by_po_number(hash[:po_number])
                   order_item = order.order_items.build(
                     # item_seq_number: i,
                     amazon_product_identifier: hash[:asin],
                     ordered_quantity_amount: hash[:quantity_requested],
                     ordered_quantity_unit_of_measure: hash[:no_data],
                     ordered_quantity_unit_size: hash[:no_data],
                     back_order_allowed: hash[:no_data],
                     netcost_amount: hash[:no_data],
                     netcost_currency_code: hash[:no_data],
                     listprice_amount: hash[:no_data],
                     listprice_currency_code: hash[:no_data],
                     case_quantity: hash[:no_data]
                   )
                   item = Item.find_by_asin(order_item.amazon_product_identifier)
                   order_item.item_id = item.id
                   order_item.vendor_product_identifier = item.item_code
                   order_item.save
                 end
               end
  end
end
