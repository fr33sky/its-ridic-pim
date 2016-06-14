class ExpenseReceiptsController < ApplicationController
  before_action :set_expense_receipt, only: [:show, :edit, :update, :destroy]

  # GET /expense_receipts
  # GET /expense_receipts.json
  def index
    @expense_receipts = ExpenseReceipt.all
  end

  # GET /expense_receipts/1
  # GET /expense_receipts/1.json
  def show
  end

  # GET /expense_receipts/new
  def new
    @expense_receipt = ExpenseReceipt.new
  end

  # GET /expense_receipts/1/edit
  def edit
  end

  # POST /expense_receipts
  # POST /expense_receipts.json
  def create
    @expense_receipt = ExpenseReceipt.new(expense_receipt_params)

    respond_to do |format|
      if @expense_receipt.save
        format.html { redirect_to @expense_receipt, notice: 'Expense receipt was successfully created.' }
        format.json { render :show, status: :created, location: @expense_receipt }
      else
        format.html { render :new }
        format.json { render json: @expense_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expense_receipts/1
  # PATCH/PUT /expense_receipts/1.json
  def update
    respond_to do |format|
      if @expense_receipt.update(expense_receipt_params)
        format.html { redirect_to @expense_receipt, notice: 'Expense receipt was successfully updated.' }
        format.json { render :show, status: :ok, location: @expense_receipt }
      else
        format.html { render :edit }
        format.json { render json: @expense_receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expense_receipts/1
  # DELETE /expense_receipts/1.json
  def destroy
    @expense_receipt.destroy
    respond_to do |format|
      format.html { redirect_to expense_receipts_url, notice: 'Expense receipt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expense_receipt
      @expense_receipt = ExpenseReceipt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def expense_receipt_params
      params.require(:expense_receipt).permit(:description)
    end
end
