class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.all
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if @contact.save
        format.html { redirect_to @contact, flash: { success: 'Contact was successfully created.' }}
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to @contact, flash: { success: 'Contact was successfully updated.' }}
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url, flash: { error: 'Contact was successfully destroyed.' }}
      format.json { head :no_content }
    end
  end

  def fetch
    # Make QBO Request SELECT * FROM Contact active WHERE active = true
    # Compare to what is in DB.  If none exists, create it and redirect to index.
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)
    customer_service = Quickbooks::Service::Customer.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)
    query = "SELECT * FROM Customer WHERE active = true"
    customer_service.query_in_batches(query, per_page: 1000) do |batch|
      batch.each do |account|
        if Contact.where(name: account.display_name).count == 0
          Contact.create!(name: account.display_name, qbo_id: account.id)
        end
      end
    end
    redirect_to contacts_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:name, :address, :city, :state, :postal_code, :country, :email_address)
    end
end
