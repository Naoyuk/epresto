# frozen_string_literal: true

class OrdersController < ApplicationController
  def index
    @search = Order.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @orders = @search.result.page(params[:page])
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
        redirect_to ({ action: :index }), alert: "Error: \"#{@orders['errors'][0]['code']}\", Contact ePresto administrator."
      end
    end
  end

  def create; end

  def update; end

  def acknowledge
    Order.acknowledge(params[:po_number])
    @orders = Order.all
    redirect_to({ action: :index })
  end
end
