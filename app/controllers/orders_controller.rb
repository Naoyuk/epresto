# frozen_string_literal: true

class OrdersController < ApplicationController
  def index
    @search = Order.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @orders = @search.result.page(params[:page])
    # TODO: 以下のオブジェクトをちゃんと条件ごとにセットする
    @orders_acknowledged = @orders
    @orders_rejected = @orders
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
