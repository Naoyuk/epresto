# frozen_string_literal: true

class AmazonAPIClient
  # RubyがNet::HTTPHeaderにヘッダを渡す時にcapitalizeしてしまう
  # AmazonAPIは小文字のままにしてほしいのでハックしておく
  require 'uri'
  require 'net/http'

  module Net::HTTPHeader
    def capitalize(name)
      name
    end
    private :capitalize
  end

  def initialize
    @refresh_token = ENV['DEV_CENTRAL_REFRESH_TOKEN']
    @client_id = ENV['AWS_ACCESS_KEY_ID']
    @client_secret = ENV['AWS_SECRET_ACCESS_KEY']
  end

  def get_purchase_orders(created_after, created_before)
    # signatureとurlを取得
    params_for_get_url_and_sign = {
      path: '/vendor/orders/v1/purchaseOrders',
      method: 'GET',
      created_after:,
      created_before:
    }
    url_and_sign = generate_url_and_sign(params_for_get_url_and_sign)

    # access_tokenを取得
    access_token = fetch_access_token

    # SP-APIのgetPurchaseOrdersのレスポンスを取得して返す
    params_for_get_purchase_order = {
      method: 'get',
      url: url_and_sign[:url],
      signature: url_and_sign[:signature],
      access_token:
    }
    send_http_request(params_for_get_purchase_order)
  end

  def build_acknowledge_request_body(orders)
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

        unless item.acks.exists?
          # acknowledgementsデータがなければ作成
          order_builder = OrderBuilder.new
          order_builder.create_acknowledgement(order, item)
        end

        # acknowledgementsデータからRequestBodyを作成
        acknowledge_detail['acknowledgementCode'] = item.acks[0].acknowledgement_code
        acknowledge_detail['scheduledShipDate'] = item.acks[0].scheduled_ship_date.to_fs(:iso8601)
        acknowledge_detail['scheduledDeliveryDate'] = item.acks[0].scheduled_delivery_date.to_fs(:iso8601)
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

  def submit_acknowledgements(req_body)
    # signatureとurlを取得
    params_for_get_url_and_sign = {
      path: '/vendor/orders/v1/acknowledgements',
      method: 'POST',
      req_body:
    }
    url_and_sign = generate_url_and_sign(params_for_get_url_and_sign)

    # access_tokenを取得
    access_token = fetch_access_token

    # acknowledgementsをsubmitする
    params_for_submit_acknowledgements = {
      method: 'post',
      content_type: 'application/json',
      url: url_and_sign[:url],
      signature: url_and_sign[:signature],
      body: JSON.dump(url_and_sign[:body_values]),
      access_token:
    }

    send_http_request(params_for_submit_acknowledgements)
    # begin
    #   send_http_request(params_for_submit_acknowledgements)
    # rescue => e
    #   puts e
    # end
  end

  private

  def fetch_access_token
    JSON.parse(self.generate_access_token(@refresh_token, @client_id, @client_secret))['access_token']
  end

  def generate_url_and_sign(params)
    # POs: params include :api, :path, :created_after, :created_before
    # Acknowledgement: params include :api, :po_number, :req_body

    host = hostname
    service = 'execute-api'
    region = 'us-east-1'
    endpoint = "https://#{host}"
    path = params[:path]
    if params[:path].include?('purchaseOrders')
      start_date = params[:created_after].to_date.to_fs(:iso8601).gsub(':', '%3A')
      end_date = params[:created_before].to_date.to_fs(:iso8601).gsub(':', '%3A')
      limit = 100
      query_hash = {
        'limit' => limit,
        'createdAfter' => start_date,
        'createdBefor' => end_date,
        'sortOrder' => 'DESC'
      }
      query = formatted_query(query_hash)
      url = URI("#{endpoint}#{path}?#{query}")
    elsif params[:path].include?('acknowledgements')
      body_values = params[:req_body]
      url = URI("#{endpoint}#{path}")
    end

    signer = Aws::Sigv4::Signer.new(
      service: service,
      region: region,
      access_key_id: ENV['IAM_ACCESS_KEY'],
      secret_access_key: ENV['IAM_SECRET_ACCESS_KEY']
    )

    params_for_get_sign = {
      http_method: params[:method],
      url: url
    }

    if params[:path].include?('acknowledgements')
      params_for_get_sign[:body] = JSON.dump(body_values) if defined? body_values
    end

    signature = signer.sign_request(params_for_get_sign)

    { url:, signature:, body_values: }
  end

  def send_http_request(params)
    # params[:method], [:signature], [:access_token], [:url], [:content_type], [:body]
    # return SP-API response(JSON)

    req = Object.const_get("Net::HTTP::#{params[:method].capitalize}").new(params[:url])
    req['host'] = params[:signature].headers['host']
    req['x-amz-access-token'] = params[:access_token]
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

  def generate_access_token(refresh_token, client_id, client_secret)
    url = URI('https://api.amazon.com/auth/o2/token')

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    request.body =
      "grant_type=refresh_token&"\
      "refresh_token=#{refresh_token}&"\
      "client_id=#{client_id}&"\
      "client_secret=#{client_secret}"

    https.request(request).body
  end

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

  def hostname
    if (Rails.env.development? || Rails.env.test?)
      'sandbox.sellingpartnerapi-na.amazon.com'
      # 'sellingpartnerapi-na.amazon.com'
    else
      'sellingpartnerapi-na.amazon.com'
    end
  end
end
