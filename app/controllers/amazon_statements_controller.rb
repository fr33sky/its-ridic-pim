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
    #@amazon_statement = AmazonStatement.find(params[:id])
    #receipt = AmazonSummary.new(@amazon_statement.report_id.to_i).create_sales_receipt
    #receipt = AmazonSummary.new(eval(@amazon_statement.summary)).create_sales_receipt
    #@amazon_statement.status = "PROCESSED"
    #@amazon_statement.save

    receipt = SalesReceipt.last
    # First pass...loop through receipt and create products if they do not exist in QBO. e.g.:
    oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)
    item_service = Quickbooks::Service::Item.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)


    receipt.sales.each do |sale|
      if !sale.product.nil?
        puts "***********************"
        p sale.product
        puts "item.product.name = #{sale.product.name}"
        puts "item.product.price = #{sale.product.price}"
        puts "***********************"
        # Query QB to see if product exists.  If not, create it.
        items = item_service.query("SELECT * FROM Item WHERE sku = '#{sale.product.upc}'")
        if items.count == 0
          item = Quickbooks::Model::Item.new
          item.expense_account_id = 31
          item.type = "NonInventory"
          item.name = sale.product.name
          item.description = sale.product.name
          item.unit_price = sale.product.price
          item.sku = sale.product.upc
          p item
        end
        begin
          item_service.create(item)
        rescue Exception => e
          puts "**************** QBO ERROR *******************"
          p e
          puts "**************** QBO ERROR *******************"
        end
      end
    end

    # THIS WORKS TO CREATE A VENDOR
    #oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, QboConfig.first.token, QboConfig.first.secret)
    #service = Quickbooks::Service::Vendor.new(:access_token => oauth_client, :company_id => QboConfig.realm_id)
    #vendor = Quickbooks::Model::Vendor.new
    #vendor.display_name = "C3PO"
    #vendor.email_address = "c3po@d2.com"
    #service.create(vendor)

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
end
