class IncomeAccountsController < ApplicationController
  before_action :set_income_account, only: [:show, :edit, :update, :destroy]

  # GET /income_accounts
  # GET /income_accounts.json
  def index
    @income_accounts = IncomeAccount.all
  end

  # GET /income_accounts/1
  # GET /income_accounts/1.json
  def show
  end

  # GET /income_accounts/new
  def new
    @income_account = IncomeAccount.new
  end

  # GET /income_accounts/1/edit
  def edit
  end

  # POST /income_accounts
  # POST /income_accounts.json
  def create
    @income_account = IncomeAccount.new(income_account_params)

    respond_to do |format|
      if @income_account.save
        format.html { redirect_to @income_account, notice: 'Income account was successfully created.' }
        format.json { render :show, status: :created, location: @income_account }
      else
        format.html { render :new }
        format.json { render json: @income_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /income_accounts/1
  # PATCH/PUT /income_accounts/1.json
  def update
    respond_to do |format|
      if @income_account.update(income_account_params)
        format.html { redirect_to @income_account, notice: 'Income account was successfully updated.' }
        format.json { render :show, status: :ok, location: @income_account }
      else
        format.html { render :edit }
        format.json { render json: @income_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /income_accounts/1
  # DELETE /income_accounts/1.json
  def destroy
    @income_account.destroy
    respond_to do |format|
      format.html { redirect_to income_accounts_url, notice: 'Income account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def fetch
    # Make QBO Request SELECT * FROM Account WHERE AccountType = 'Income' AND active = true
    # Compare to what is in DB.  If none exists, create it and redirect to index.
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)
    income_account_service = Quickbooks::Service::Account.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)
    accounts = income_account_service.query("SELECT * FROM Account WHERE AccountType = 'Income' AND active = true")
    accounts.entries.each do |entry|
      if IncomeAccount.where(name: entry.name).count == 0
        IncomeAccount.create!(name: entry.name, description: entry.description, qbo_id: entry.id)
      end
    end
    redirect_to bank_accounts_path
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_income_account
    @income_account = IncomeAccount.find(params[:id])
  end

    # Never trust parameters from the scary internet, only allow the white list through.
    def income_account_params
      params.require(:income_account).permit(:name, :description, :qbo_id)
    end
end
