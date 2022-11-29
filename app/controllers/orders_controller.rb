# frozen_string_literal: true

class OrdersController < ApplicationController
  def index
    @search = Order.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @orders_all = @search.result.page(params[:page])
    @orders_new = @search.result.where('po_state = ?', 0).page(params[:page])
    @orders_acknowledged = @search.result.where('po_state = ?', 1).page(params[:page])
    @orders_rejected = @search.result.includes(order_items: :acks).references(:acks).where(:acks => { acknowledgement_code: 2 }).page(params[:page])
    @orders_closed = @search.result.where('po_state = ?', 2).page(params[:page])

    if params[:new]
      @orders = @orders_new
      @state = 'new'
    elsif params[:acknowledged]
      @orders = @orders_acknowledged
      @state = 'acknowledged'
    elsif params[:rejected]
      @orders = @orders_rejected
      @state = 'rejected'
    elsif params[:closed]
      @orders = @orders_closed
      @state = 'closed'
    else
      @orders = @orders_all
      @state = 'all'
    end
    # TODO: POのインポート時のエラーをflashで表示したい
    # @import_errors.each do |k, v|
    #   v.each do |msg|
    #     flash.now[:k] = msg
    #   end
    # end

    respond_to do |format|
      format.html
      format.xlsx do
        response.headers['Content-Disposition'] =
          "attachment; filename=#{@state.capitalize}_PO_#{@orders[0].po_date.strftime('%Y%m%d_%H%M%S')}.xlsx"
      end
      format.csv do |_csv|
        output_csv(@orders)
      end
    end
  end

  def show; end

  def import
    if params[:created_after].blank? || params[:created_before].blank?
      redirect_to ({ action: :index }), alert: 'Error: "From" and "To" are required.'
    else
      created_after = params[:created_after].to_datetime
      created_before = params[:created_before].to_datetime + 24 * 60 * 60
      response = Order.import_po(current_user.vendor_id, created_after, created_before)

      # 取得したPOから作成したOrderのidとエラーのどちらか又は両方が返ってくる
      order_ids = response[:orders]
      @orders = Order.where(id: order_ids)
      errors = response[:errors]

      # if @orders.count > 0
      #   redirect_to orders_path
      # else
      if errors.size == 0
        error_message = nil
      else
        errors_formatted = []
        errors.each { |error| errors_formatted << "Error Code: #{error[:code]}, #{error[:desc]}" }
        error_message = "#{errors_formatted.join('<br>')}<br>Contact to an administrator."
      end
      redirect_to orders_path, alert: error_message
      # end
    end
  end

  def create; end

  def update; end

  def acknowledge
    @cost_difference_notice = Order.acknowledge(params[:po_numbers])
    unless @cost_difference_notice.nil?
      redirect_to orders_path
      # TODO: Phase2でPriceの違うオーダーがある場合に警告を出力するバージョン
      # redirect_to orders_path, :alert => @cost_difference_notice.gsub("\n", '<br>')
    else
      redirect_to orders_path
    end
  end

  def output_csv(orders)
    ts = Time.now.to_fs(:file)
    filename = "PO-#{ts}.zip"
    temppath = "#{Rails.root}/tmp/#{filename}"
    Zip::File.open(temppath, Zip::File::CREATE) do |zipfile|
      orders.each do |order|
        zipfile.get_output_stream("PO-#{order.po_number}-#{ts}.csv") do |f|
          f.puts(
            CSV.generate do |csv|
              csv << [order.po_type]
              csv << [order.po_number]
              csv << [order.ship_window_from.to_fs(:js_file)]
              csv << [order.ship_to_party_id]
              csv << ['0' * 12 + '988']
              order.order_items.each do |item|
                csv << [0, item.vendor_product_identifier, item.ordered_quantity_amount, 0, 0, 0]
              end
            end
          )
        end
      end
    end
    send_data File.read(temppath), filename: filename, type: 'application/zip'
    File.delete(temppath)
  end
end
