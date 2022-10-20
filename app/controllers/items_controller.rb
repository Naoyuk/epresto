class ItemsController < ApplicationController
  def index
    @search = Item.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @items = @search.result.page(params[:page])
  end
end
