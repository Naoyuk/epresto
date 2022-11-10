# frozen_string_literal: true

class OrdersController < ApplicationController
  def index
    @search = Order.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @orders = @search.result.page(params[:page])
  end

  def show; end

  def import
    @orders = Order.import_po(current_user.vendor_id)
    if @orders.is_a?(String)
      redirect_to ({ action: :index }), notice: "Error: \"#{@orders}\", Contact ePresto administrator."
    else
      redirect_to({ action: :index })
    end
  end

  def create; end

  def update; end
end
