# frozen_string_literal: true

class ItemsController < ApplicationController
  def index
    @search = Item.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @items = @search.result.page(params[:page])
  end

  def import
    Item.import(params[:file])
    redirect_to items_url
  end
end
