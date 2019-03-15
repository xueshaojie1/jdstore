class Admin::VouchersController < ApplicationController

  layout "admin"

  before_action :authenticate_user!
  before_action :admin_required

  def index
    @vouchers = Voucher.order("id DESC")
  end

  def new
    @voucher = Voucher.new
  end

  def create
    @voucher = Voucher.new(voucher_params)
    if @voucher.save
      redirect_to admin_vouchers_path
    else
      render :new
    end
  end

  def update
    @voucher = Voucher.find(params[:id])

    if voucher_params["aasm_state"] == "invalid"
      @voucher.admin_valid!
      redirect_to admin_vouchers_path
    elsif voucher_params["aasm_state"] == "valid_no_used"
      @voucher.admin_invalid!
      redirect_to admin_vouchers_path
    else
      render :back
    end
  end


  private

  def voucher_params
    params.require(:voucher).permit(:start_at, :end_at, :amount, :aasm_state)
  end

end
