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
      :z_pricing,
      :stock,
      :dept,
      :status,
      :mixed_code,
      :asin,
      :model_number,
      :description,
      :case,
      :vendor_code,
      :vendor_sku,
      :product_type,
      :item_name,
      :brand_name,
      :external_product_id,
      :external_product_id_type,
      :merchant_suggested_asin,
      :ean,
      :gtin
    )
  end

  def admin_scan
    unless current_user.sysadmin?
      redirect_to root_path
    end
  end
end
