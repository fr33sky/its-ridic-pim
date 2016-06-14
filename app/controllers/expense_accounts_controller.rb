class ExpenseAccountsController < ApplicationController
  before_action :set_expense_account, only: [:show, :edit, :update, :destroy]

  # GET /expense_accounts
  # GET /expense_accounts.json
  def index
    @expense_accounts = ExpenseAccount.all
  end

  # GET /expense_accounts/1
  # GET /expense_accounts/1.json
  def show
  end

  # GET /expense_accounts/new
  def new
    @expense_account = ExpenseAccount.new
  end

  # GET /expense_accounts/1/edit
  def edit
  end

  # POST /expense_accounts
  # POST /expense_accounts.json
  def create
    @expense_account = ExpenseAccount.new(expense_account_params)

    respond_to do |format|
      if @expense_account.save
        format.html { redirect_to @expense_account, notice: 'Expense account was successfully created.' }
        format.json { render :show, status: :created, location: @expense_account }
      else
        format.html { render :new }
        format.json { render json: @expense_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expense_accounts/1
  # PATCH/PUT /expense_accounts/1.json
  def update
    respond_to do |format|
      if @expense_account.update(expense_account_params)
        format.html { redirect_to @expense_account, notice: 'Expense account was successfully updated.' }
        format.json { render :show, status: :ok, location: @expense_account }
      else
        format.html { render :edit }
        format.json { render json: @expense_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expense_accounts/1
  # DELETE /expense_accounts/1.json
  def destroy
    @expense_account.destroy
    respond_to do |format|
      format.html { redirect_to expense_accounts_url, notice: 'Expense account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def fetch
    # Make QBO Request SELECT * FROM Account WHERE Classification = 'Expense' AND active = true
    # Compare to what is in DB.  If none exists, create it and redirect to index.
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)
    expense_account_service = Quickbooks::Service::Account.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)
    accounts = expense_account_service.query("SELECT * FROM Account WHERE Classification = 'Expense' AND active = true")
    accounts.entries.each do |entry|
      if ExpenseAccount.where(name: entry.name).count == 0
        ExpenseAccount.create!(name: entry.name, description: entry.description, qbo_id: entry.id)
      end
    end
    redirect_to expense_accounts_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expense_account
      @expense_account = ExpenseAccount.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def expense_account_params
      params.require(:expense_account).permit(:name, :description, :qbo_id)
    end
end
