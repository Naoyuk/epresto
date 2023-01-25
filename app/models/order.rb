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
      req_body = create_request_body(orders)

      # SP-APIのsubmitAcknowledgementを叩く
      response = amazon_api.submit_acknowledgements(req_body)
      JSON.parse(response.body)

      # @cost_difference_notice
    end

    #
    #
    #
    #
    # TODO: RequestBuilderクラスに移動
    # インスタンスメソッドにする
    # request_builder = RequestBuilder.new
    # request_builder.create_request_body(orders)
    def create_request_body(orders)
      # return
      req_body = {}
      acknowledgements = []
      # price_diff_items = []

      orders.each do |order|
        acknowledgement_date = Time.now.to_fs(:iso8601)
        order_body = {}
        order_body["purchaseOrderNumber"] = order.po_number unless order.po_number.nil?
        selling_party = {}
        selling_party["partyId"] = order.selling_party_id unless order.selling_party_id.nil?
        selling_party_address = {}
        selling_party_address["name"] = order.selling_address_name unless order.selling_address_name.nil?
        selling_party_address["addressLine1"] = order.selling_address_line1 unless order.selling_address_line1.nil?
        selling_party_address["addressLine2"] = order.selling_address_line2 unless order.selling_address_line2.nil?
        selling_party_address["addressLine3"] = order.selling_address_line3 unless order.selling_address_line3.nil?
        selling_party_address["city"] = order.selling_address_city unless order.selling_address_city.nil?
        selling_party_address["county"] =
          order.selling_address_country_code unless order.selling_address_country_code.nil?
        selling_party_address["district"] = order.selling_address_district unless order.selling_address_district.nil?
        selling_party_address["stateOrRegion"] =
          order.selling_address_state_or_region unless order.selling_address_state_or_region.nil?
        selling_party_address["postalCode"] =
          order.selling_address_postal_code unless order.selling_address_postal_code.nil?
        selling_party_address["countryCode"] =
          order.selling_address_country_code unless order.selling_address_country_code.nil?
        selling_party_address["phone"] = order.selling_address_phone unless order.selling_address_phone.nil?
        selling_party["address"] = selling_party_address unless selling_party_address.empty?
        order_body["sellingParty"] = selling_party unless selling_party.empty?
        order_body["acknowledgementDate"] = acknowledgement_date
        tax_info = {}
        tax_info["taxRegistrationType"] = order.buying_tax_type unless order.buying_tax_type.nil?
        tax_info["taxRegistrationNumber"] = order.buying_tax_number unless order.buying_tax_number.nil?
        order_body["taxInfo"] = tax_info unless tax_info.empty?

        items = []
        order.order_items.each do |item|
          item_body = {}
          item_body["itemSequenceNumber"] = item.item_seq_number unless item.item_seq_number.nil?
          item_body["amazonProductIdentifier"] =
            item.amazon_product_identifier unless item.amazon_product_identifier.nil?
          item_body["vendorProductIdentifier"] =
            item.vendor_product_identifier unless item.vendor_product_identifier.nil?
          ordered_quantity = {}
          ordered_quantity["amount"] = item.ordered_quantity_amount unless item.ordered_quantity_amount.nil?
          ordered_quantity["unitOfMeasure"] =
            item.ordered_quantity_unit_of_measure unless item.ordered_quantity_unit_of_measure.nil?
          ordered_quantity["unitSize"] = item.ordered_quantity_unit_size unless item.ordered_quantity_unit_size.nil?
          item_body["orderedQuantity"] = ordered_quantity unless ordered_quantity.empty?
          net_cost = {}
          net_cost["currencyCode"] = item.netcost_currency_code unless item.netcost_currency_code.nil?
          net_cost["amount"] = item.netcost_amount.to_s unless item.netcost_amount.nil?
          item_body['netCost'] = net_cost unless net_cost.empty?
          list_price = {}
          list_price["currencyCode"] = item.listprice_currency_code unless item.listprice_currency_code.nil?
          list_price["amount"] = item.listprice_amount.to_s unless item.listprice_amount.nil?
          item_body["listPrice"] = list_price unless list_price.empty?

          item_acknowledgements = []
          acknowledge_detail = {}
          if item.acks.exists?
            acknowledge_detail['acknowledgementCode'] =
              item.acks[0].acknowledgement_code unless item.acks[0].acknowledgement_code.nil?
            acknowledge_detail['scheduledShipDate'] =
              item.acks[0].scheduled_ship_date.to_fs(:iso8601) unless item.acks[0].scheduled_ship_date.nil?
            acknowledge_detail['scheduledDeliveryDate'] =
              item.acks[0].scheduled_delivery_date.to_fs(:iso8601) unless item.acks[0].scheduled_delivery_date.nil?
            acknowledge_detail['rejectionReason'] =
              item.acks[0].rejection_reason unless item.acks[0].rejection_reason.nil?

            acknowledged_quantity = {}
            acknowledged_quantity['amount'] =
              item.acks[0].acknowledged_quantity_amount unless item.acks[0].acknowledged_quantity_amount.nil?
            acknowledged_quantity['unitOfMeasure'] =
              item.acks[0].acknowledged_quantity_unit_of_measure unless item.acks[0].acknowledged_quantity_unit_of_measure.nil?
            acknowledged_quantity['unitSize'] =
              item.acks[0].acknowledged_quantity_unit_size unless item.acks[0].acknowledged_quantity_unit_size.nil?
            acknowledge_detail['acknowledgedQuantity'] = acknowledged_quantity unless acknowledged_quantity.empty?
            item_acknowledgements << acknowledge_detail unless acknowledge_detail.empty?
          else
            ack = item.acks.build
            ack.acknowledged_quantity_amount = item.ordered_quantity_amount
            ack.acknowledged_quantity_unit_of_measure = item.ordered_quantity_unit_of_measure
            ack.acknowledged_quantity_unit_size = item.ordered_quantity_unit_size
            window = item.order.ship_window
            # window_from = window.slice(0, window.index('--'))
            window_to = window&.slice(window.index('--') + 2..window.size)
            ack.scheduled_ship_date = window
            if item.order.ship_to_address_state_or_region == 'BC'
              # Shipping within B.C. = 3 days
              ack.scheduled_delivery_date = (Time.now + 3).to_fs(:iso8601)
            elsif item.order.ship_to_address_state_or_region == 'AB'
              # Calgary = 1 week
              ack.scheduled_delivery_date = (Time.now + 7).to_fs(:iso8601)
            elsif item.order.ship_to_address_state_or_region == 'ON'
              # Ontario = 3 weeks
              ack.scheduled_delivery_date = (Time.now + 21).to_fs(:iso8601)
            else
              # Not given any directions
            end
            if item.item.Current?
              ack.acknowledgement_code = 'Accepted'
              acknowledge_detail['acknowledgementCode'] = 'Accepted'
              # TODO: Phase2以降の実装内容。Price違いの警告
              # unless item.listprice_amount == item.item.price
              #   @notice_title ||= 'Prices for the following items differ from Item Master prices.'
              #   price_diff_items << "\nASIN: #{item.amazon_product_identifier}, PO Price: #{item.listprice_amount}, Item Master Price: #{item.item.price}"
              # end
            else
              ack.acknowledgement_code = 'Rejected'
              acknowledge_detail['acknowledgementCode'] = 'Rejected'
            end
            unless window.nil?
              acknowledge_detail['scheduledShipDate'] = window_to.to_fs(:iso8601)
              acknowledge_detail['scheduledDeliveryDate'] = ack.scheduled_delivery_date
            end
            if item.item.nil?
              ack.rejection_reason = 'InvalidProductIdentifier'
              acknowledge_detail['rejectionReason'] = 'InvalidProductIdentifier'
            elsif item.item.Discontinued?
              ack.rejection_reason = 'ObsoleteProduct'
              acknowledge_detail['rejectionReason'] = 'ObsoleteProduct'
              # elsif item.item.price != item.listprice_amount
              #   # TODO: Phase2以降でこの条件は実装予定
              #   ack.rejection_reason = 'TemporarilyUnavailable'
              #   acknowledge_detail['rejectionReason'] = 'TemporarilyUnavailable'
            end
            ack.save
            item_acknowledgements << acknowledge_detail unless acknowledge_detail.empty?

            # TODO: 以下はPhase2以降で実装予定
            # if # 在庫がオーダー数よりも少なかった場合
            #   # 配列itemAcknowledgementを1個追加
            #   acknowledge_additional = acknowledge_detail
            #   acknowledged_additional_quantity = {}
            #   if item.item.Current? && (item.listprice_amount == item.item.price)
            #     acknowledge_additional['acknowledgementCode'] = 'Accepted'
            #   elsif # バックオーダーの条件
            #     acknowledge_additional['acknowledgementCode'] = 'Backordered'
            #     acknowledge_additional['rejectionReason'] = 'TemporarilyUnavailable'
            #   else
            #     # ディスコンの場合
            #     acknowledge_additional['acknowledgementCode'] = 'Rejected'
            #     acknowledge_additional['rejectionReason'] = 'ObsoleteProduct'
            #   end
            #   acknowledged_additional_quantity['amount'] = item.ordered_quantity_amount -
            #   acknowledged_additional_quantity['unitOfMeasure'] = item.acks.acknowledged_quantity_unit_of_measure
            #   acknowledged_additional_quantity['unitSize'] = item.acks.acknowledged_quantity_unit_size
            #   acknowledge_additional['acknowledgedQuantity'] = acknowledged_additional_quantity

            #   item_acknowledgements << acknowledge_additional
            # end
          end
          item_body['itemAcknowledgements'] = item_acknowledgements unless item_acknowledgements.empty?

          items << item_body
        end
        # TODO: これもPahse2以降で実装予定のPrice違いの警告
        # unless price_diff_items.size == 0
        #   @cost_difference_notice = @notice_title + "\n" + price_diff_items.join(',')
        # end
        order_body['items'] = items
        acknowledgements << order_body
      end
      req_body["acknowledgements"] = acknowledgements
      return req_body
    end

    def hostname
      if (Rails.env.development? || Rails.env.test?)
        'sandbox.sellingpartnerapi-na.amazon.com'
        # 'sellingpartnerapi-na.amazon.com'
      else
        'sellingpartnerapi-na.amazon.com'
      end
    end
  end
end
