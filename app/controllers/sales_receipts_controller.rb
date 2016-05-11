class SalesReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show, :edit, :update, :destroy]

  def index
    @sales_receipts = SalesReceipt.all
  end

  def show
  end

  def new
    @sales_receipt = SalesReceipt.new
  end

  def edit
  end

  def update
    respond_to do |format|
      if @sales_receipt.update(sales_receipt_params)
        format.html { redirect_to @sales_receipt, notice: 'Sales Receipt was successfully updated.' }
        format.json { render :show, status: :ok, location: @sales_receipt }
      else
        format.html { render :edit }
        format.json { render json: @sales_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @sales_receipt = SalesReceipt.new(sales_receipt_params)

    respond_to do |format|
      if @sales_receipt.save
        format.html { redirect_to @sales_receipt, notice: 'Sales Receipt was successfully created.' }
        format.json { render :show, status: :created, location: @sales_receipt }
      else
        format.html { render :new }
        format.json { render json: @sales_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @sales_receipt.destroy
    respond_to do |format|
      format.html { redirect_to sales_receipt_path, notice: 'Sales Receipt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_receipt
    @sales_receipt = SalesReceipt.find(params[:id])
  end

  def sales_receipt_params
    params.require(:sales_receipt).permit(:contact_id, :payment_id, :user_date, sales_attributes: [:id, :quantity, :product_id, :sales_receipt_id, :amount, :rate])
  end
end
