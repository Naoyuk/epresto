# frozen_string_literal: true

class OrdersController < ApplicationController
  def index
    @search = Order.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @orders = @search.result.page(params[:page])
  end

  def show; end

  def import
    Order.import(params[:file], current_user.vendor_id)
    redirect_to orders_url
  end

  def create; end

  def update; end
end
