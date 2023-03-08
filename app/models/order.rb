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

    def import_purchase_orders_history(file)
      # Excelファイルで保存していた過去のPurchase Orderの取り込み
      # One time usage
      # インポートファイルの読み込み
      xls = Roo::Excelx.new(file)

      # インポート対象のシートとカラム名を取得
      sheet = xls.sheet(xls.sheets[0])

      # vendor_idを取得
      vendor_id = Vendor.find_by_name('CCW').id

      # 一つでも失敗したレコードがあれば処理を中止したいのでトランザクションする
      ActiveRecord::Base.transaction do
        # エクセルの各行からOrderのデータを作成
        sheet.each(po_number: 'PO', vendor: 'Vendor', po_date: 'Ordered On', location: 'Ship to location',
                   window_type: 'Window Type', window_start: 'Window Start', window_end: 'Window End') do |hash|
                     unless hash[:po_number] == 'PO'
                       order = Order.new
                       order.po_number = hash[:po_number]
                       order.vendor_code = hash[:vendor]
                       order.po_date = Order.hash_date_to_datetime(hash[:po_date])
                       location_code = hash[:location].slice(0..3)
                       ship_to = Shipto.find_by_location_code(location_code)
                       order.shipto_id = ship_to.id
                       order.ship_to_party_id = location_code
                       order.ship_window_from = Order.hash_date_to_datetime(hash[:window_start])
                       order.ship_window_to = Order.hash_date_to_datetime(hash[:window_end])
                       order.ship_window = "#{order.ship_window_from.to_fs(:iso8601)}--#{order.ship_window_to.to_fs(:iso8601)}"
                       order.po_state = 2
                       order.payment_method = 0
                       order.vendor_id = vendor_id
                       order.save
                     end
                   end
        puts 'Order History records are successfully imported.'
      rescue => e
        puts "PO Number: #{order.po_number}"
        puts order.errors.full_messages
        puts 'Error has occured.'
        puts e
      end
    end

    def hash_date_to_datetime(string)
      year = string.slice(6, 4)
      month = string.slice(0, 2)
      day = string.slice(3, 2)
      Time.zone.parse("#{year}-#{month}-#{day} 10:00:00")
    end

    def import_order_items_history(file)
      # Excelファイルで保存していた過去のOrderItemsの取り込み
      # One time usage
      # インポートファイルの読み込み
      xls = Roo::Excelx.new(file)

      # インポート対象のシートとカラム名を取得
      sheet = xls.sheet(xls.sheets[0])

      # 一つでも失敗したレコードがあれば処理を中止したいのでトランザクションする
      ActiveRecord::Base.transaction do
        sheet.each_with_index(po_number: 'PO', vendor: 'Vendor', location: 'Ship to location', asin: 'ASIN',
                              external_id: 'External ID', external_id_type: 'External Id Type',
                              model_number: 'Model Number', title: 'Title', availability: 'Availability',
                              window_type: 'Window Type', window_start: 'Window Start', window_end: 'Window End',
                              quantity_requested: 'Quantity Requested', accepted_quantity: 'Accepted Quantity',
                              case_quantity: 'Quantity Correction', unit_cost: 'Unit Cost') do |hash, i|
          unless hash[:po_number] == 'PO'
            order = Order.find_by_po_number(hash[:po_number])
            order_item = order.order_items.build(
              item_seq_number: i + 1,
              amazon_product_identifier: hash[:asin],
              vendor_product_identifier: hash[:external_id],
              ordered_quantity_amount: hash[:quantity_requested],
              netcost_amount: hash[:unit_cost],
              netcost_currency_code: 'CAD',
              listprice_currency_code: 'CAD'
            )
            item = Item.find_by_asin(order_item.amazon_product_identifier)
            if item&.Case?
              order_item.ordered_quantity_unit_of_measure = 0
            else
              order_item.ordered_quantity_unit_of_measure = 1
            end
            unless hash[:case_quantity].nil? || hash[:case_quantity] == 0
              unless order_item.ordered_quantity_amount.nil?
                order_item.pack = order_item.ordered_quantity_amount / hash[:case_quantity]
              end
            end
            unless hash[:title].nil?
              order_item.title = hash[:title]
            else
              order_item.title = order_item&.item&.title
            end
            unless hash[:availability].nil?
              order_item.availability = hash[:availability]
            else
              if order_item&.item&.Current?
                order_item.availability = 0
              elsif order_item&.item&.Discontinued?
                order_item.availability = 1
              elsif order_item&.item&.Future?
                order_item.availability = 2
              else
                order_item.availability = nil
              end
            end
            order_item.pack = order_item&.item&.pack
            order_item.ordered_quantity_unit_size = order_item.pack
            order_item.convert_case_quantity
            order_item.save

            ack = order_item.acks.build
            ack.acknowledged_quantity_amount = order_item.ordered_quantity_amount
            ack.acknowledged_quantity_unit_of_measure = order_item.ordered_quantity_unit_of_measure
            ack.acknowledged_quantity_unit_size = order_item.ordered_quantity_unit_size
            ack.scheduled_ship_date = order.ship_window_to
            ack.scheduled_delivery_date = order.shipto&.transit_time&.business_days&.after(order.ship_window_to)

            if order_item&.item&.Current?
              ack.acknowledgement_code = 'Accepted'
            else
              ack.acknowledgement_code = 'Rejected'
            end

            if order_item&.item&.nil?
              ack.rejection_reason = 'InvalidProductIdentifier'
            elsif order_item&.item&.Discontinued?
              ack.rejection_reason = 'ObsoleteProduct'
            end
            ack.save
          end
        end
        puts 'Order History records are successfully imported.'
      rescue => e
        puts "PO Number: #{order.po_number}"
        puts order.errors.full_messages
        puts 'Error has occured.'
        puts e
      end
    end
  end
end
