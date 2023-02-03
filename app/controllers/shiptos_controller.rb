# frozen_string_literal: true

class ShiptosController < ApplicationController
  before_action :admin_scan

  def index
    @search = Shipto.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @shiptos = @search.result.page(params[:page])
  end

  def show
    @shipto = Shipto.find(params[:id])
  end

  def new
    @shipto = Shipto.new
  end

  def edit
    @shipto = Shipto.find(params[:id])
  end

  def create
    @shipto = Shipto.new(shipto_params)

    if @shipto.save
      flash.now.notice = 'A new location was successfully created.'
      redirect_to :index
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @shipto = Shipto.find(params[:id])
    if @shipto.update(shipto_params)
      render @shipto
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @shipto = Shipto.find(params[:id])
    @shipto.destroy
    flash.now.notice = 'The location was successfully deleted.'
  end

  private

  def shipto_params
    params.require(:shipto).permit(
      :location_code,
      :province,
      :customer_name,
      :address_line1,
      :address_line2,
      :city,
      :postal_code,
      :transit_time,
      :contact_name1,
      :contact_name2,
      :email1,
      :email2,
      :phone1,
      :phone2,
      :send_report,
      :visu_email
    )
  end

  def admin_scan
    unless current_user.sysadmin?
      redirect_to root_path
    end
  end
end
