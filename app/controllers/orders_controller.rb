# frozen_string_literal: true

class OrdersController < ApplicationController
  def index
    # debugger
    @search = Order.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @orders_new = @search.result.where('po_state = ?', 0).page(params[:page])
    @orders_acknowledged = @search.result.where('po_state = ?', 1).page(params[:page])
    @orders_rejected = @search.result.includes(order_items: :acks).references(:acks).where(:acks => {acknowledgement_code: 0}).page(params[:page])
    @orders_closed = @search.result.where('po_state = ?', 2).page(params[:page])

    if params[:new]
      @orders = @orders_new
    elsif params[:acknowledged]
      @orders = @orders_acknowledged
    elsif params[:rejected]
      @orders = @orders_rejected
    elsif params[:closed]
      @orders = @orders_closed
    else
      @orders = @search.result.page(params[:page])
    end
    # TODO: 以下のオブジェクトをちゃんと条件ごとにセットする
    # @orders_new = Order.where('po_state = ?', 0)
    # @orders_acknowledged = Order.includes(order_items: :acks).references(:acks).where(:acks => {acknowledgement_code: 0})
    # @orders_rejected = Order.includes(order_items: :acks).references(:acks).where(:acks => {acknowledgement_code: 2})
    # @orders_closed = Order.where('po_state = ?', 2)
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
          "attachment; filename=PO_#{@orders[0].po_date.strftime('%Y%m%d_%H%M%S')}.xlsx"
      end
    end
  end

  def show; end

  def import
    if params[:created_after].blank? || params[:created_before].blank?
      redirect_to ({ action: :index }), alert: 'Error: "From" and "To" are required.'
    else
      @orders = Order.import_po(current_user.vendor_id, params[:created_after], params[:created_before])
      if @orders.kind_of?(ActiveRecord::Relation)
        redirect_to({ action: :index })
      else
        redirect_to ({ action: :index }),
                    alert: "Error: \"#{@orders['errors'][0]['code']}\", Contact ePresto administrator."
      end
    end
  end

  def create; end

  def update; end

  def acknowledge
    Order.acknowledge(params[:po_numbers])
    @orders = Order.all
    redirect_to({ action: :index })
  end
end
