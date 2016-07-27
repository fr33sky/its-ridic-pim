class AmazonStatementsController < ApplicationController
  before_action :set_qb_service, only: [:show]
  # GET /amazon_statements
  # GET /amazon_statements.json
  def index
    @amazon_statements = AmazonStatement.all
  end

  def fetch
    client = set_client
    begin
      reports = client.get_report_list
      next_token = reports.next_token
      fetch_reports(client, reports)
      fetch_rest_of_reports(client, next_token)
    rescue => e
      puts "*" * 5_000
      logger.fatal(e.to_s)
      logger.warn e.response.message
    end
    redirect_to amazon_statements_path
  end

  def show
    @amazon_statement = AmazonStatement.find(params[:id])

    # CREATE SALES RECEIPT in App and in QBO
    # TO DO: Move this off into a callable method and split into multiple methods

    # Find other way to convert string to hash besides eval...
    receipt = AmazonSummary.new(eval(@amazon_statement.summary)).create_sales_receipt

    # For testing purposes, do not set the status to PROCESSED yet
    #@amazon_statement.status = "PROCESSED"
    #@amazon_statement.save

    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)
    item_service = Quickbooks::Service::Item.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)

    # Set up SalesReceipt in QBO
    @receipt_service = Quickbooks::Service::SalesReceipt.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)

    qbo_receipt = Quickbooks::Model::SalesReceipt.new({
      customer_id: Config.sales_receipt_customer,
      txn_date: Date.parse(receipt.user_date.to_s),
      deposit_to_account_id: Config.sales_receipt_deposit_account
    })
    qbo_receipt.auto_doc_number!


    # Loop through and create items if necessary in QBO
    receipt.sales.each do |sale|
      if !sale.product.nil?
        if sale.product.qbo_id.nil?
          # Query QB to see if product exists.  If not, create it.
          items = item_service.query("SELECT * FROM Item WHERE sku = '#{sale.product.upc}'")
          p items
          if items.count == 0
            item = Quickbooks::Model::Item.new
            item.income_account_id = Config.sales_receipt_income_account
            item.type = "NonInventory"
            item.name = sale.product.upc
            item.description = sale.product.name
            item.unit_price = sale.product.price
            item.sku = sale.product.upc
            p item
          else
            sale.product.qbo_id = items.entries[0].id
            sale.product.save
          end
          begin
            created_item = item_service.create(item)
            sale.product.qbo_id = created_item.id
            sale.product.save
          rescue Exception => e
            puts "**************** QBO ERROR 1 *******************"
            p e
            puts "**************** QBO ERROR 1 *******************"
          end
        end
      else
        prod = sale.description.gsub(" ", "_").camelize
        items = item_service.query("SELECT * FROM Item WHERE name = '#{prod}'")
        if items.entries.count == 0
          # Create Item in QBO
          item = Quickbooks::Model::Item.new
          item.income_account_id = classify_income_account(prod)
          item.type = "NonInventory"
          item.name = prod
          item.description = prod
          item.unit_price = sale.rate
          begin
            created_item = item_service.create(item)
          rescue Exception => e
            puts "**************** QBO ERROR 2 *******************"
            p e
            puts "**************** QBO ERROR 2 *******************"
          end
        else
          sale.qbo_id = items.entries[0].id
          sale.save!
        end
      end
    end

    receipt.sales.each do |sale|
      line_item = Quickbooks::Model::Line.new
      line_item.amount = sale.amount.to_f
      line_item.description = sale.description
      line_item.sales_item! do |detail|
        unless sale.quantity * sale.rate == line_item.amount
          sale.amount = sale.quantity * sale.rate
          sale.save!
          line_item.amount = sale.quantity * sale.rate
        end
        detail.unit_price = sale.rate.to_f
        detail.quantity = sale.quantity
        if sale.product.present?
          detail.item_id = sale.product.qbo_id
        else
          detail.item_id = sale.qbo_id
        end
      end
      qbo_receipt.line_items << line_item
    end

    qbo_receipt.line_items.each do |li|
      p li
    end

    created_receipt = @receipt_service.create(qbo_receipt)
    p created_receipt

    # CREATE EXPENSE RECEIPT IN QBO
    create_expense_receipt(@amazon_statement.period, oauth_client)

    # CREATE JOURNAL ENTRY/COGS
    create_journal_entry(oauth_client, receipt)

    redirect_to sales_receipt_path(receipt)
  end

  def set_client
    MWS::Reports::Client.new(
      primary_marketplace_id: Credential.last.primary_marketplace_id,
      merchant_id: Credential.last.merchant_id,
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      auth_token: Credential.last.auth_token
    )
  end

  def fetch_reports(client, reports, next_token = false)
    report_param = { true =>  { 1 => "GetReportListByNextTokenResponse", 2 => "GetReportListByNextTokenResult" },
                     false => { 1 => "GetReportListResponse", 2 => "GetReportListResult" } }
    reports.xml[report_param[next_token][1]][report_param[next_token][2]]['ReportInfo'].each do |report|
      type = report['ReportType']
      if type.include?('_GET_V2_SETTLEMENT_REPORT_DATA_XML_')
        report_id = report['ReportId']
        item_to_add = client.get_report(report_id).xml['AmazonEnvelope']['Message']['SettlementReport']
        add_statement_to_db(item_to_add, report_id)
      else
        next
      end
    end
  end

  def add_statement_to_db(item_to_add, report_id)
    if AmazonStatement.where(settlement_id: item_to_add['SettlementData']['AmazonSettlementID']).blank?
      period = item_to_add['SettlementData']['StartDate'].gsub(/T.+/, '') + ' - ' + item_to_add['SettlementData']['EndDate'].gsub(/T.+/, '')
      deposit_total = item_to_add['SettlementData']['TotalAmount']['__content__']
      status = 'NOT_PROCESSED'
      summary = item_to_add.to_s
      settlement_id = item_to_add['SettlementData']['AmazonSettlementID']
      AmazonStatement.create!(period: period, deposit_total: deposit_total, status: status, summary: summary, settlement_id: settlement_id, report_id: report_id)
    end
  end

  def fetch_rest_of_reports(client, next_token)
    loop do
      break if next_token == false
      reports = client.get_report_list_by_next_token(next_token)
      next_token = reports.next_token
      fetch_reports(client, reports, true)
    end
  end

  def amazon_statement_params
    params.require(:amazon_statement).permit(:period, :deposit_total, :status, :settlement_id, :summary)
  end

  def authenticate
    callback = oauth_callback_amazon_statements_url
    puts "callback: "
    p callback
    token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = Marshal.dump(token)
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def oauth_callback
    at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    puts "at:"
    p at
    puts "Adding to database..."
    QboConfig.create(token: at.token, secret: at.secret, realm_id: params['realmId'])
    p QboConfig.last
    flash.notice = "Your QuickBooks account has been successfully linked."
    @msg = 'Redirecting. Please wait.'
    @url = amazon_statements_path
    render 'close_and_redirect', layout: false
  end  

  private

  def set_qb_service
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)
    @vendor_service = Quickbooks::Service::Vendor.new
    @vendor_service.access_token = oauth_client
    @vendor_service.company_id = QboConfig.realm_id
  end

  def classify_income_account(prod)
    # TO DO: Move these to a setup question (Config model) so user can define which accounts
    # they want to go to
    if prod == 'Shipping'
      # Use "Shipping Income" account
      Config.classify_shipping_income
    elsif prod == 'SaleTax'
      # Use "Sale Tax Payable" account
      config.classify_sale_tax
    elsif prod == 'PromotionShipping'
      # Use "Promo Rebates on Shipping" account
      Config.classify_promotion_shipping
    elsif prod == 'ShippingSalesTax'
      # Use Sale Tax Payable:FBAShippingTax" account
      Config.classify_shipping_sales_tax
    elsif prod == 'FBAgiftwrap'
      # Use "Services" account
      Config.classify_fba_gift_wrap
    elsif prod == 'BalanceAdjustment'
      # Use "Gross Receipts" account
      Config.classify_balance_adjustment
    elsif prod == 'GiftWrapTax'
      Config.classify_gift_wrap_tax
    else
      # Use "Service" account
      Config.classify_unknown
    end
  end

  def create_expense_receipt(desc, oauth_client)
    # Create Expense Receipt in App
    expense_receipt = AmazonSummary.new(eval(@amazon_statement.summary)).create_expense_receipt(desc)
    puts "<><><><><><><><><><><><><><><><><><><><><>"
    p expense_receipt
    puts "<><><><><><><><><><><><><><><><><><><><><>"
    # Create Expense Receipt in QBO
    purchase_service = Quickbooks::Service::Purchase.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)
    purchase = Quickbooks::Model::Purchase.new
    purchase.payment_type = 'Cash'
    purchase.account_id = Config.expense_bank_account.qbo_id
    purchase.line_items = []
    # Loop through all expenses and create new model for it.
    expense_receipt.expenses.each do |expense|
      line_item = Quickbooks::Model::PurchaseLineItem.new
      line_item.amount = expense.amount
      line_item.description = expense.description
      line_item.account_based_expense! do |detail|
        detail.account_id = expense.account.qbo_id
        detail.customer_id = 65 # TO DO: Need to add qbo_id to Contact...
      end
      purchase.line_items << line_item
    end
    result = purchase_service.create(purchase)
  end

  def create_journal_entry(oauth_client, receipt)
    # Lookup / Create Accounts in QBO
    # STEP 1: FIND "Inventory Asset" ACCOUNT
    account_service = Quickbooks::Service::Account.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)
    accounts = account_service.query("SELECT * FROM Account WHERE name = 'Inventory Asset'")
    inventory_asset_account_id = accounts.entries[0].id.to_i
    # STEP 2: Lookup / Create SubAccounts for Items (if they do not exist):
    Product.all.each do |prod|
      # Check to see if id is already stored in DB
      if prod.inventory_asset_account_id.nil?
        account = account_service.query("SELECT * FROM Account WHERE name = 'Inventory - #{prod.upc}'")
        p account
        if account.entries.count == 0
          puts "THIS ACCOUNT DOES NOT EXIST.  CREATING IN QBO..."
          new_account = Quickbooks::Model::Account.new(name: "Inventory - #{prod.upc}", classification: "Asset", 
                                                       parent_id: inventory_asset_account_id, account_type: "Other Current Asset",
                                                       account_sub_type: "Inventory")
          p new_account
          result = account_service.create(new_account)
          p result
          puts "THE ACCOUNT ID TO BE SAVE IS: #{result.id}"
          prod.inventory_asset_account_id = result.id
          prod.save
        else
          # ID not in DB, but exists in QBO
          puts "ID does not exist in DB, but does in QBO. Adding to DB..."
          prod.inventory_asset_account_id = account.entries[0].id
          prod.save
        end
      end
    end
    # STEP 3: Create Journal Entry
    journal_entry_service = Quickbooks::Service::JournalEntry.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)
    journal_entry = Quickbooks::Model::JournalEntry.new
    receipt.sales.each do |sale|
      if sale.product and sale.quantity > 0
        # Create Credit Line
        line_item_credit = Quickbooks::Model::Line.new
        average_cost = sale.product.average_cost(receipt.user_date)
        description = "Sale of #{sale.quantity} at #{average_cost}"
        line_item_credit.description = description
        line_item_credit.amount      = average_cost
        line_item_credit.detail_type = 'JournalEntryLineDetail'
        jel = Quickbooks::Model::JournalEntryLineDetail.new
        jel.posting_type = 'Credit'
        #jel.tax_code_id = 2
        #jel.tax_applicable_on = 'Credit'
        jel.account_id = sale.product.inventory_asset_account_id
        line_item_credit.journal_entry_line_detail = jel
        journal_entry.line_items << line_item_credit

        # Create Debit Line
        line_item_credit = Quickbooks::Model::Line.new
        average_cost = sale.product.average_cost(receipt.user_date)
        description = "Sale of #{sale.quantity} at #{average_cost}"
        line_item_credit.description = description
        line_item_credit.amount      = average_cost
        line_item_credit.detail_type = 'JournalEntryLineDetail'
        jel = Quickbooks::Model::JournalEntryLineDetail.new
        jel.posting_type = 'Debit'
        #jel.tax_code_id = 2
        #jel.tax_applicable_on = 'Credit'
        jel.account_id = 80 # TO DO: Set up question! 80 = Sandbox2
        line_item_credit.journal_entry_line_detail = jel
        journal_entry.line_items << line_item_credit
      end
    end
    result = journal_entry_service.create(journal_entry)
    p result
  end
end
