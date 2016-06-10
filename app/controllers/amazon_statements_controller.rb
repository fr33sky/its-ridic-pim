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
      puts "*" * 10_000
      logger.fatal(e.to_s)
      redirect_to amazon_statements_path
    end
    redirect_to amazon_statements_path
  end

  def show
    @amazon_statement = AmazonStatement.find(params[:id])
    receipt = AmazonSummary.new(@amazon_statement.report_id.to_i).create_sales_receipt
    receipt = AmazonSummary.new(eval(@amazon_statement.summary)).create_sales_receipt
    #@amazon_statement.status = "PROCESSED"
    #@amazon_statement.save

    # First pass...loop through receipt and create products if they do not exist in QBO. e.g.:
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)
    item_service = Quickbooks::Service::Item.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)

    # Set up SalesReceipt in QBO
    @receipt_service = Quickbooks::Service::SalesReceipt.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)
    # These will eventually need stored in DB as a sort of set up question (e.g. which payment method do you want to use for QBO Sales Receipts from Amazon?)
    qbo_receipt = Quickbooks::Model::SalesReceipt.new({
      customer_id: 65,
      txn_date: Date.parse(receipt.user_date.to_s),
      deposit_to_account_id: 4,
      payment_method_id: 2
    })
    qbo_receipt.auto_doc_number!


    # Loop through and create items if necessary in QBO
    receipt.sales.each do |sale|
      if !sale.product.nil?
        puts "***********************"
        p sale.product
        puts "item.product.name = #{sale.product.name}"
        puts "item.product.price = #{sale.product.price}"
        puts "***********************"
        # Query QB to see if product exists.  If not, create it.
        items = item_service.query("SELECT * FROM Item WHERE sku = '#{sale.product.upc}'")
        p items
        if items.count == 0
          item = Quickbooks::Model::Item.new
          item.income_account_id = 82
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
          puts "**************** QBO ERROR *******************"
          p e
          puts "**************** QBO ERROR *******************"
        end
      else
        prod = sale.description.gsub(" ", "_").camelize
        items = item_service.query("SELECT * FROM Item WHERE name = '#{prod}'")
        puts "++++++++++++++++++++++++++++++++++++++++++++++++"
        puts "SELECT * FROM Item WHERE name = '#{prod}'"
        p items
        puts "++++++++++++++++++++++++++++++++++++++++++++++++"
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
            puts "**************** QBO ERROR *******************"
            p e
            puts "**************** QBO ERROR *******************"
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
        puts "()()()()()()()()()"
        puts "detail.unit_price = #{sale.rate.to_f}"
        puts "detail.quantity = #{sale.quantity}"
        puts "sale.amount = #{sale.amount}"
        unless sale.quantity * sale.rate == line_item.amount
          sale.amount = sale.quantity * sale.rate
          sale.save!
          line_item.amount = sale.quantity * sale.rate
        end
        puts "quantity * rate == amount? #{sale.quantity * sale.rate == line_item.amount}"
        puts "()()()()()()()()()"
        detail.unit_price = sale.rate.to_f
        detail.quantity = sale.quantity
        if sale.product.present?
          detail.item_id = sale.product.qbo_id
        else
          detail.item_id = sale.qbo_id
        end
      end
      qbo_receipt.line_items << line_item
      puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
      p line_item
      p line_item.valid?
      puts "^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    end

    qbo_receipt.line_items.each do |li|
      p li
    end

    created_receipt = @receipt_service.create(qbo_receipt)
    p created_receipt

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
    token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback)
    session[:qb_request_token] = Marshal.dump(token)
    redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
  end

  def oauth_callback
    at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
    QboConfig.create(token: at.token, secret: at.secret, realm_id: params['realmId'])
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
    if prod == 'Shipping'
      # Use "Shipping Income" account
      91
    elsif prod == 'SaleTax'
      # Use "Sale Tax Payable" account
      94
    elsif prod == 'PromotionShipping'
      # Use "Promo Rebates on Shipping" account
      97
    elsif prod == 'ShippingSalesTax'
      # Use Sale Tax Payable:FBAShippingTax" account
      95
    elsif prod == 'FBAgiftwrap'
      # Use "Services" account
      1
    elsif prod == 'BalanceAdjustment'
      # Use "Gross Receipts" account
      96
    elsif prod == 'GiftWrapTax'
      94
    else
      # Use "Service" account
      1
    end
  end
end
