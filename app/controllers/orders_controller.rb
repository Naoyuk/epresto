# frozen_string_literal: true

class OrdersController < ApplicationController
  def index
    params[:q][:po_number_cont_any] = params[:q][:po_number_cont_any].split(/\p{blank}/) unless params[:q].blank? || params[:q][:po_number_cont_any].blank?
    @search = Order.ransack(params[:q])
    if params[:q].nil?
      # ransackの検索条件がない場合はPO Dateが今週のOrderをデフォルト検索範囲とする
      po_date_gteq = Time.zone.now.beginning_of_week
      po_date_lteq = Time.zone.now.end_of_week
      @search = Order.ransack(po_date_gteq:, po_date_lteq:)
      # @search.po_date_gteq = po_date_gteq
      # @search.po_date_lteq = po_date_lteq
    elsif params[:q][:po_date_gteq].nil? && params[:q][:po_date_lteq].nil?
      # ransackの検索条件にpo_dateがない場合はPO Dateが今週のOrderをデフォルト検索範囲とする
      po_date_gteq = Time.zone.now.beginning_of_week
      po_date_lteq = Time.zone.now.end_of_week
      @search = Order.ransack(po_date_gteq:, po_date_lteq:)
      # @search.po_date_gteq = po_date_gteq
      # @search.po_date_lteq = po_date_lteq
    end
    @search.sorts = 'id desc' if @search.sorts.empty?

    if params[:tab] == 'new'
      @orders = @search.result.where('po_state = ?', 0).page(params[:page])
      @state = 'new'
    elsif params[:tab] == 'acknowledged'
      @orders = @search.result.where('po_state = ?', 1).page(params[:page])
      @state = 'acknowledged'
    elsif params[:tab] == 'rejected'
      @orders = @search.result.includes(order_items: :acks).references(:acks).where(:acks => { acknowledgement_code: 2 }).page(params[:page])
      @state = 'rejected'
    elsif params[:tab] == 'closed'
      @orders = @search.result.where('po_state = ?', 2).page(params[:page])
      @state = 'closed'
    elsif params[:tab] == 'bulk'
      @orders = @search.result.page(params[:page])
      @state = 'bulk'
    else
      @orders = @search.result.page(params[:page])
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
      created_after = Time.zone.parse(params[:created_after])
      created_before = Time.zone.parse(params[:created_before])
      Order.import_purchase_orders(current_user.vendor_id, created_after, created_before)

      # 取得したPOから作成したOrderのOrderオブジェクトとエラーのどちらか又は両方が返ってくる
      # @orders = response[:orders]
      # errors = response[:errors]

      # if @orders.count > 0
      #   redirect_to orders_path
      # else
      # if errors.size == 0
      #   error_message = nil
      # else
      #   errors_formatted = []
      #   errors.each { |error| errors_formatted << "Error Code: #{error[:code]}, #{error[:desc]}" }
      #   error_message = "#{errors_formatted.join('<br>')}<br>Contact to an administrator."
      # end
      # redirect_to orders_path(tab: 'new'), alert: error_message
      redirect_to orders_path(tab: 'new')
    end
  end

  def create; end

  def update; end

  def acknowledge
    @cost_difference_notice = Order.acknowledge(params[:po_numbers])
    unless @cost_difference_notice.nil?
      redirect_to orders_path(tab: 'acknowledged')
      # TODO: Phase2でPriceの違うオーダーがある場合に警告を出力するバージョン
      # redirect_to orders_path, :alert => @cost_difference_notice.gsub("\n", '<br>')
    else
      redirect_to orders_path(tab: 'acknowledged')
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
                csv << [0, item.item&.item_code, item.case_quantity, 0, 0, 0]
              end
            end
          )
        end
      end
    end
    send_data File.read(temppath), filename: filename, type: 'application/zip'
    File.delete(temppath)
  end

  def convert_to_regular
    @ids = params[:ids]
    if @ids.empty?
      return redirect_to orders_path(tab: 'bulk'), alert: 'No purchase orders are selected.'
    end

    toggle_po_type(:regular)

    redirect_to orders_path(tab: 'bulk'), notice: 'Selected purchase orders are set to Regular Order.'
  end

  def convert_to_bulk
    @ids = params[:ids]
    if @ids.empty?
      return redirect_to orders_path(tab: 'bulk'), alert: 'No purchase orders are selected.'
    end

    toggle_po_type(:bulk)

    redirect_to orders_path(tab: 'bulk'), notice: 'Selected purchase orders are set to Bulk Order.'
  end

  private

  def toggle_po_type(type)
    type_int = type == :regular ? 0 : 3
    ids_array = @ids.split(',')
    ids_array.each do |id|
      o = Order.find(id)
      o.update(po_type: type_int)
    end
  end
end
