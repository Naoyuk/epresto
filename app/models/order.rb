# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :vendor
  has_many :order_items

  # Class methods
  def self.import_po(vendor_id)
    pos = fetch_po(vendor_id)
    # posが文字列の場合はエラーなのでそのままコントローラに返す
    return pos if pos.is_a?(String)

    # posからOrdersとOrderItemsにレコードを作成していく
    pos['payload']['orders'].each do |order|
      # Ordersの作成
      odr = Order.find_or_initialize_by(po_number: order['purchaseOrderNumber'])
      odr.vendor_id = vendor_id
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
      odr.delivery_window = order['shipWindow']
      # odr.deal_code = order['orderDetails']['dealCode']
      # odr.import_method_of_payment = order['orderDetails']['importDetails']['methodOfPayment']
      # odr.import_international_commercial_terms = order['orderDetails']['importDetails']['internationalCommercialTerms']
      # odr.import_port_of_delivery = order['orderDetails']['importDetails']['portOfDelivery']
      # odr.import_containers = order['orderDetails']['importdetails']['importContainers']
      # odr.import_shipping_instructions = order['orderDetails']['importdetails']['shippingInstructions']
      # odr.buying_address_name = order['orderDetails']['buyingParty']['address']['name']
      # odr.buying_address_line1 = order['orderDetails']['buyingParty']['address']['addressLine1']
      # odr.buying_address_city = order['orderDetails']['buyingParty']['address']['city']
      # odr.buying_address_state_or_region = order['orderDetails']['buyingParty']['address']['stateOrRegion']
      # odr.buying_address_postal_code = order['orderDetails']['buyingParty']['address']['postalCode']
      # odr.buying_address_country_code = order['orderDetails']['buyingParty']['address']['countryCode']
      # odr.buying_address_phone = order['orderDetails']['buyingParty']['address']['phone']
      # odr.ship_to_address_name = order['orderDetails']['shipToParty']['address']['name']
      # odr.ship_to_address_line1 = order['orderDetails']['shipToParty']['address']['addressLine1']
      # odr.ship_to_address_city = order['orderDetails']['shipToParty']['address']['city']
      # odr.ship_to_address_state_or_region = order['orderDetails']['shipToParty']['address']['stateOrRegion']
      # odr.ship_to_address_postal_code = order['orderDetails']['shipToParty']['address']['postalCode']
      # odr.ship_to_address_country_code = order['orderDetails']['shipToParty']['address']['countryCode']
      # odr.ship_to_address_phone = order['orderDetails']['shipToParty']['address']['phone']
      # odr.bill_to_address_name = order['orderDetails']['shipToParty']['address']['name']
      # odr.bill_to_address_line1 = order['orderDetails']['shipToParty']['address']['addressLine1']
      # odr.bill_to_address_city = order['orderDetails']['shipToParty']['address']['city']
      # odr.bill_to_address_state_or_region = order['orderDetails']['shipToParty']['address']['stateOrRegion']
      # odr.bill_to_address_postal_code = order['orderDetails']['shipToParty']['address']['postalCode']
      # odr.bill_to_address_country_code = order['orderDetails']['shipToParty']['address']['countryCode']
      # odr.bill_to_address_phone = order['orderDetails']['shipToParty']['address']['phone']
      # odr.tax_type = order['orderDetails']['taxInfo']['taxType']
      # odr.tax_registration_number = order['orderDetails']['taxInfo']['taxRegistrationNumber']
      odr.save

      # OrderItemsの作成
      order['orderDetails']['items'].each do |item|
        itm = OrderItem.find_or_initialize_by(order_id: odr.id, amazon_product_identifier: item['amazonProductIdentifier'])
        #itm.order_id = order_id
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
        itm.save
      end
    end
    Order.all
  end

  def self.fetch_po(vendor_id)
    # 最新のItemを検索
    items = Item.find_by(vendor_id: vendor_id)

    # AmazonからPOを取得
    pos_from_amazon = Order.fetch_origin
    if pos_from_amazon.is_a?(Hash)
      pos_hash = pos_from_amazon
    else
      error_message = pos_from_amazon
    end
  end

  require 'uri'
  require 'net/http'

  module Net::HTTPHeader
    def capitalize(name)
      name
    end
    private :capitalize
  end

  def self.fetch_origin
    # Request Values
    access_token = get_access_token
    access_key_id = Rails.application.credentials[:IAM_ACCESS_KEY]
    secret_access_key = Rails.application.credentials[:IAM_SECRET_ACCESS_KEY]
    method = 'GET'
    service = 'execute-api'
    host = 'sandbox.sellingpartnerapi-na.amazon.com'
    region = 'us-east-1'
    endpoint = 'https://' + host
    path = '/vendor/orders/v1/purchaseOrders'
    t = Time.now.utc
    @query_hash = {
      'limit' => 54,
      'createdAfter' => (t - 24*60*60*7).strftime("%Y-%m-%dT%H:%M:%S").gsub(':', '%3A'),
      'createdBefor' => t.strftime("%Y-%m-%dT%H:%M:%S").gsub(':', '%3A'),
      'sortOrder' => 'DESC'
    }

    query = Order.formatted_query
    url = URI(endpoint + path + '?' + query)

    signer = Aws::Sigv4::Signer.new(
      service: service,
      region: region,
      access_key_id: access_key_id,
      secret_access_key: secret_access_key
    )

    signature = signer.sign_request(
      http_method: method,
      url: url
    )

    req = Net::HTTP::Get.new(url)
    req['host'] = signature.headers['host']
    # req['x-amz-access-token'] = signature.headers['x-amz-access-token']
    req['x-amz-access-token'] = access_token
    req['x-amz-date'] = signature.headers['x-amz-date']
    req['x-amz-content-sha256'] = signature.headers['x-amz-content-sha256']
    req['Authorization'] = signature.headers['authorization']

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    res = https.request(req)

    return JSON.parse(res.read_body) if res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.read_body)['errors'][0]['code']
  end

  def self.formatted_query
    list = []
    @query_hash.each_pair do |k, v|
      k = k.downcase
      list << [k, v]
    end

    list.sort.map do |k, v|
      "#{k}=#{v}"
    end.join('&')
  end

  def self.get_access_token
    url = URI("https://api.amazon.com/auth/o2/token")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    access_key = Rails.application.credentials[:AWS_ACCESS_KEY_ID]
    secret_key = Rails.application.credentials[:AWS_SECRET_ACCESS_KEY]
    refresh_token = Rails.application.credentials[:DEV_CENTRAL_REFRESH_TOKEN]

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request.body = "grant_type=refresh_token&refresh_token=#{refresh_token}&client_id=#{access_key}&client_secret=#{secret_key}"

    response = https.request(request)
    JSON.parse(response.body)['access_token']
  end

  # 取得したPOをOrdersテーブルとOrderItemsテーブルにUpdate Import
  #import_to_orders(pos_hash)

  # Acknowledgeする
  #@orders = acknowledge(pos_from_amazon, items)

  def self.import_to_orders(pos)
    #pos['
  end

  # Instance methods
  def acknowledge(items)
  end
end
