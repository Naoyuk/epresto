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

    host = 'sellingpartnerapi-na.amazon.com'
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
end
