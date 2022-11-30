# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :admin_scan

  def index
    @search = Item.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @items = @search.result.page(params[:page])
  end

  def import
    Item.import(params[:file], current_user.vendor_id)
    redirect_to items_url
  end

  def admin_scan
    unless current_user.sysadmin?
      redirect_to new_user_session_path
    end
  end
end
