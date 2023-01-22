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
    # TODO: AmazonApiクラスに移動
    # インスタンスメソッドにする
    # api = AmazonApi.new
    # access_token = api.generate_access_token(refresh_token, client_id, clinet_secret)
    # になるようにする
    def generate_access_token
      url = URI('https://api.amazon.com/auth/o2/token')

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request['Content-Type'] = 'application/x-www-form-urlencoded'
      request.body =
        "grant_type=refresh_token&"\
        "refresh_token=#{ENV['DEV_CENTRAL_REFRESH_TOKEN']}&"\
        "client_id=#{ENV['AWS_ACCESS_KEY_ID']}&"\
        "client_secret=#{ENV['AWS_SECRET_ACCESS_KEY']}"

      https.request(request).body
    end

    def import_po(vendor_id, created_after, created_before)
      # AmazonからPOを取得
      params = {
        api: 'pos',
        vendor_id:,
        path: '/vendor/orders/v1/purchaseOrders',
        created_after:,
        created_before:
      }
      response = get_purchase_orders(params)
      pos = JSON.parse(response.body)
      # なんらかのエラーでPOを取得できなかったらエラーコードをviewに渡して終了
      return pos if pos.has_key?('errors')

      # posからOrdersとOrderItemsにレコードを作成していく
      params = { pos:, vendor_id: }
      response = create_order_and_order_items(params)

      # GETしたPOを元に作成したOrderのオブジェクト、またはエラーを返す
      errors = response[:errors]
      { orders: Order.where(po_number: response[:po_numbers].split(' ')).ids, errors: }
    end

    # TODO: AmazonApiクラスに移動
    # インスタンスメソッドにする
    # api = AmazonApi.new
    # response = api.get_purchase_orders(params)
    def get_purchase_orders(params)
      url_and_signature = generate_url_and_sign(params)

      request_params = {
        method: 'get',
        url: url_and_signature[:url],
        signature: url_and_signature[:signature]
      }

      send_http_request(request_params)
    end

    # TODO: OrderBuilderクラスに移動
    # インスタンスメソッドにする
    # order_builder = OrderBuilder.new
    # order_builder.create_order_and_order_items(response)
    def create_order_and_order_items(params)
      po_numbers = []
      errors = []
      params[:pos]['payload']['orders'].each do |order|
        # Ordersの作成
        odr = find_or_initialize_by(po_number: order['purchaseOrderNumber'])
        odr.vendor_id = params[:vendor_id]
        odr.po_number = order['purchaseOrderNumber']
        odr.po_state = order['purchaseOrderState']
        odr.po_date = order['orderDetails']['purchaseOrderDate']
        odr.po_changed_date = order['orderDetails']['purchaseOrderChangedDate']
        odr.po_state_changed_date = order['orderDetails']['purchaseOrderStateChangedDate']
        odr.po_type = order['orderDetails']['purchaseOrderType']
        odr.payment_method = order['orderDetails']['paymentMethod']
        odr.buying_party_id = order['orderDetails']['buyingParty']['partyId']
        odr.selling_party_id = order['orderDetails']['sellingParty']['partyId']
        odr.ship_to_party_id = order['orderDetails']['shipToParty']['partyId']
        odr.bill_to_party_id = order['orderDetails']['billToParty']['partyId']
        odr.ship_window = order['orderDetails']['shipWindow']

        unless odr.ship_to_party_id.nil?
          odr.shipto_id = Shipto.find_by(location_code: odr.ship_to_party_id).id
        end

        unless odr.ship_window.nil?
          pos_of_div = odr.ship_window.index('--')
          from = odr.ship_window.slice(0, pos_of_div)
          to = odr.ship_window.slice(pos_of_div + 2, 20)
          odr.ship_window_from = DateTime.new(
            from.slice(0, 4).to_i, from.slice(5, 2).to_i, from.slice(8, 2).to_i,
            from.slice(11, 2).to_i, from.slice(14, 2).to_i, from.slice(17, 2).to_i
          )
          odr.ship_window_to = DateTime.new(
            to.slice(0, 4).to_i, to.slice(5, 2).to_i, to.slice(8, 2).to_i,
            to.slice(11, 2).to_i, to.slice(14, 2).to_i, to.slice(17, 2).to_i
          )
        end

        odr.delivery_window = calc_delivery_window(odr.ship_to_party_id, odr.po_date)
        odr.deal_code = order['orderDetails']['dealCode'] unless order['orderDetails'].nil?
        unless order['orderDetails']['importDetails'].nil?
          odr.import_method_of_payment = order['orderDetails']['importDetails']['methodOfPayment']
          odr.import_international_commercial_terms =
            order['orderDetails']['importDetails']['internationalCommercialTerms']
          odr.import_port_of_delivery = order['orderDetails']['importDetails']['portOfDelivery']
          odr.import_containers = order['orderDetails']['importDetails']['importContainers']
          odr.import_shipping_instructions = order['orderDetails']['importDetails']['shippingInstructions']
        end
        unless order['orderDetails']['sellingParty'].nil?
          unless order['orderDetails']['sellingParty']['address'].nil?
            odr.selling_address_name = order['orderDetails']['sellingParty']['address']['name']
            odr.selling_address_line1 = order['orderDetails']['sellingParty']['address']['addressLine1']
            odr.selling_address_line2 = order['orderDetails']['sellingParty']['address']['addressLine2']
            odr.selling_address_line3 = order['orderDetails']['sellingParty']['address']['addressLine3']
            odr.selling_address_city = order['orderDetails']['sellingParty']['address']['city']
            odr.selling_address_district = order['orderDetails']['sellingParty']['address']['district']
            odr.selling_address_state_or_region = order['orderDetails']['sellingParty']['address']['stateOrRegion']
            odr.selling_address_postal_code = order['orderDetails']['sellingParty']['address']['postalCode']
            odr.selling_address_country_code = order['orderDetails']['sellingParty']['address']['countryCode']
            odr.selling_address_phone = order['orderDetails']['sellingParty']['address']['phone']
          end
        end
        unless order['orderDetails']['buyingParty'].nil?
          unless order['orderDetails']['buyingParty']['address'].nil?
            odr.buying_address_name = order['orderDetails']['buyingParty']['address']['name']
            odr.buying_address_line1 = order['orderDetails']['buyingParty']['address']['addressLine1']
            odr.buying_address_line2 = order['orderDetails']['buyingParty']['address']['addressLine2']
            odr.buying_address_line3 = order['orderDetails']['buyingParty']['address']['addressLine3']
            odr.buying_address_city = order['orderDetails']['buyingParty']['address']['city']
            odr.buying_address_district = order['orderDetails']['buyingParty']['address']['district']
            odr.buying_address_state_or_region = order['orderDetails']['buyingParty']['address']['stateOrRegion']
            odr.buying_address_postal_code = order['orderDetails']['buyingParty']['address']['postalCode']
            odr.buying_address_country_code = order['orderDetails']['buyingParty']['address']['countryCode']
            odr.buying_address_phone = order['orderDetails']['buyingParty']['address']['phone']
          end
        end
        unless order['orderDetails']['shipToParty'].nil?
          unless order['orderDetails']['shipToParty']['address'].nil?
            odr.ship_to_address_name = order['orderDetails']['shipToParty']['address']['name']
            odr.ship_to_address_line1 = order['orderDetails']['shipToParty']['address']['addressLine1']
            odr.ship_to_address_line2 = order['orderDetails']['shipToParty']['address']['addressLine2']
            odr.ship_to_address_line3 = order['orderDetails']['shipToParty']['address']['addressLine3']
            odr.ship_to_address_city = order['orderDetails']['shipToParty']['address']['city']
            odr.ship_to_address_district = order['orderDetails']['shipToParty']['address']['district']
            odr.ship_to_address_state_or_region = order['orderDetails']['shipToParty']['address']['stateOrRegion']
            odr.ship_to_address_postal_code = order['orderDetails']['shipToParty']['address']['postalCode']
            odr.ship_to_address_country_code = order['orderDetails']['shipToParty']['address']['countryCode']
            odr.ship_to_address_phone = order['orderDetails']['shipToParty']['address']['phone']
          end
        end
        unless order['orderDetails']['billToParty'].nil?
          unless order['orderDetails']['billToParty']['address'].nil?
            odr.bill_to_address_name = order['orderDetails']['billToParty']['address']['name']
            odr.bill_to_address_line1 = order['orderDetails']['billToParty']['address']['addressLine1']
            odr.bill_to_address_line2 = order['orderDetails']['billToParty']['address']['addressLine2']
            odr.bill_to_address_line3 = order['orderDetails']['billToParty']['address']['addressLine3']
            odr.bill_to_address_city = order['orderDetails']['billToParty']['address']['city']
            odr.bill_to_address_district = order['orderDetails']['billToParty']['address']['district']
            odr.bill_to_address_state_or_region = order['orderDetails']['billToParty']['address']['stateOrRegion']
            odr.bill_to_address_postal_code = order['orderDetails']['billToParty']['address']['postalCode']
            odr.bill_to_address_country_code = order['orderDetails']['billToParty']['address']['countryCode']
            odr.bill_to_address_phone = order['orderDetails']['billToParty']['address']['phone']
          end
        end
        unless order['orderDetails']['taxInfo'].nil?
          odr.buying_tax_type = order['orderDetails']['taxInfo']['taxType']
          odr.buying_tax_number = order['orderDetails']['taxInfo']['taxRegistrationNumber']
        end

        if odr.valid?
          odr.save
          po_numbers << odr.po_number
        else
          error = {
            code: '100',
            desc: 'Import Purchase Order Error',
            messages: odr.errors.full_messages
          }
          errors << error
        end

        # OrderItemsの作成
        order['orderDetails']['items'].each do |item|
          itm = OrderItem.find_or_initialize_by(
            order_id: odr.id,
            amazon_product_identifier: item['amazonProductIdentifier']
          )
          # itm.order_id = order_id
          # itm.item_id = Item.find_by(asin: item['amazonProductIdentifier'])&.id
          itm.item_seq_number = item['itemSequenceNumber']
          itm.amazon_product_identifier = item['amazonProductIdentifier']
          itm.vendor_product_identifier = item['vendorProductIdentifier']
          itm.ordered_quantity_amount = item['orderedQuantity']['amount']
          itm.ordered_quantity_unit_of_measure = item['orderedQuantity']['unitOfMeasure']
          itm.ordered_quantity_unit_size = item['orderedQuantity']['unitSize']
          itm.back_order_allowed = item['isBackOrderAllowed']
          itm.netcost_amount = item['netCost']['amount'] unless item['netCost'].nil?
          itm.netcost_currency_code = item['netCost']['currencyCode'] unless item['netCost'].nil?
          itm.listprice_amount = item['listPrice']['amount'] unless item['listPrice'].nil?
          itm.listprice_currency_code = item['listPrice']['currencyCode'] unless item['listPrice'].nil?

          if itm.valid?
            itm.save
            itm.convert_case_quantity
          else
            error = {
              code: '200',
              desc: 'Import Order Item Error',
              messages: itm.errors.full_messages
            }
            errors << error
          end
        end
      end

      # 取得したPOのPurchaseOrderNumberの配列を返す
      { po_numbers:, errors: }
    end

    def acknowledge(po_numbers)
      # Acknowledgeする対象のPOを検索
      order_ids = Order.where(po_number: po_numbers.split(' ')).ids
      orders = Order.where(id: order_ids)

      # HTTPリクエストのbodyのJSONを作る
      req_body = create_request_body(orders)

      # signatureとurlを取得
      params = { api: 'acknowledgement', path: '/vendor/orders/v1/acknowledgements', req_body: }
      url_and_signature = generate_url_and_sign(params)

      request_params = {
        method: 'post',
        content_type: 'application/json',
        url: url_and_signature[:url],
        signature: url_and_signature[:signature],
        body: JSON.dump(url_and_signature[:body_values])
      }

      begin
        response = send_http_request(request_params)
      rescue => e
        puts e
      end
      JSON.parse(response.body)
      # @cost_difference_notice
    end

    require 'uri'
    require 'net/http'

    module Net::HTTPHeader
      def capitalize(name)
        name
      end
      private :capitalize
    end

    # TODO: AmazonApiクラスに移動させる
    # インスタンスメソッドにする
    # api = AmazonApi.new
    # api.generate_url_and_sign(params)
    def generate_url_and_sign(params)
      # POs: params include :api, :path
      # Acknowledgement: params include :api, :po_number, :req_body

      host = hostname
      service = 'execute-api'
      region = 'us-east-1'
      endpoint = "https://#{host}"
      path = params[:path]
      if params[:api] == 'pos'
        start_date = params[:created_after].to_date.to_fs(:iso8601).gsub(':', '%3A')
        end_date = params[:created_before].to_date.to_fs(:iso8601).gsub(':', '%3A')
        limit = 54
        method = 'GET'
        query_hash = {
          'limit' => limit,
          'createdAfter' => start_date,
          'createdBefor' => end_date,
          'sortOrder' => 'DESC'
        }
        query = formatted_query(query_hash)
        url = URI("#{endpoint}#{path}?#{query}")
      elsif params[:api] == 'acknowledgement'
        body_values = params[:req_body]
        path = '/vendor/orders/v1/acknowledgements'
        method = 'POST'
        url = URI("#{endpoint}#{path}")
      end

      api_credentials
      @access_token = JSON.parse(generate_access_token)['access_token']

      signer = Aws::Sigv4::Signer.new(
        service: service,
        region: region,
        access_key_id: ENV['IAM_ACCESS_KEY'],
        secret_access_key: ENV['IAM_SECRET_ACCESS_KEY']
      )

      if params[:api] == 'pos'
        signature = signer.sign_request(
          http_method: method,
          url: url
        )
      elsif params[:api] == 'acknowledgement'
        signature = signer.sign_request(
          http_method: method,
          url: url,
          body: JSON.dump(body_values)
        )
      end

      { url:, signature:, body_values: }
    end

    # TODO: AmazonApiクラスに移動させる
    # privateメソッドにする
    def send_http_request(params)
      # params[:method]
      # params[:signature]
      # params[:url]
      # params[:content_type]
      # params[:body]
      # return SP-API response(JSON)

      req = Object.const_get("Net::HTTP::#{params[:method].capitalize}").new(params[:url])
      req['host'] = params[:signature].headers['host']
      req['x-amz-access-token'] = @access_token
      req['user-agent'] = 'ePresto Connection1/1.0 (Language=Ruby/3.1.2)'
      req['x-amz-date'] = params[:signature].headers['x-amz-date']
      req['x-amz-content-sha256'] = params[:signature].headers['x-amz-content-sha256']
      req['Authorization'] = params[:signature].headers['authorization']
      req['Content-Type'] = params[:content_type]
      req.body = params[:body] unless params[:body].nil?

      https = Net::HTTP.new(params[:url].host, params[:url].port)
      https.use_ssl = true
      https.request(req)
    end

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

    # TODO: RequestBuilderクラスに移動
    # privateメソッドにする
    def formatted_query(query_hash)
      list = []
      query_hash.each_pair do |k, v|
        # k = k.downcase
        list << [k, v]
      end

      list.sort.map do |k, v|
        "#{k}=#{v}"
      end.join('&')
    end

    # TODO: OrderBuilderクラスに移動
    # privateメソッドにする
    def calc_delivery_window(ship_to_id, _ordered_date)
      shipto = Shipto.find_by(location_code: ship_to_id)
      province = shipto&.province
      if province == 'BC'
        (Time.now + 3).to_fs(:dat)
      elsif province == 'AB'
        (Time.now + 7).to_fs(:dat)
      elsif province == 'ON'
        (Time.now + 21).to_fs(:dat)
      else
        # Not given any information
      end
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
