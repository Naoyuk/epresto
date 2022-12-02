# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :admin_scan

  def index
    @search = Item.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @items = @search.result.page(params[:page])
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])
    if @item.update(item_params)
      render @item
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def import
    Item.import(params[:file], current_user.vendor_id)
    redirect_to items_url
  end

  private

  def item_params
    params.require(:item).permit(
      :item_code,
      :upc,
      :title,
      :brand,
      :size,
      :pack,
      :price,
      :z_price,
      :stock,
      :depertment,
      :availability_status,
      :case_upc,
      :asin,
      :ean_upc,
      :model_number,
      :description,
      :replenishment_status,
      :effective_date,
      :current_cost,
      :cost,
      :current_cost_currency,
      :cost_currency,
      :case
    )
  end

  def admin_scan
    unless current_user.sysadmin?
      redirect_to root_path
    end
  end
end
