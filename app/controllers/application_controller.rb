class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

  def set_client
    MWS::Reports::Client.new(
      primary_marketplace_id: Credential.last.primary_marketplace_id,
      merchant_id: Credential.last.merchant_id,
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      auth_token: Credential.last.auth_token
    )
  end

	def authenticate
		callback = oauth_callback_settlements_url
		token = $qb_oauth_consumer.get_request_token(:oauth_callback => callback)
		session[:qb_request_token] = Marshal.dump(token)
		redirect_to("https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token.token}") and return
	end

	# NOTE: Will Want to Persist At Some Point! (token, secret, realm_id):
	def oauth_callback
		at = Marshal.load(session[:qb_request_token]).get_access_token(:oauth_verifier => params[:oauth_verifier])
		session[:token] = at.token
		session[:secret] = at.secret
		session[:realm_id] = params['realmId']
		flash.notice = "Your QuickBooks account has been successfully linked."
		@msg = 'Redirecting. Please wait.'
		@url = settlements_path
		render 'close_and_redirect', layout: false
	end  

	private

	def set_qb_service
		oauth_client = OAuth::AccessToken.new($qb_oauth_consumer, session[:token], session[:secret])
		# @sales_receipt = Quickeebooks::Online::Service::SalesReceipt.new
		# @sales_receipt.access_token = oauth_client
		# @sales_receipt.realm_id = session[:realm_id]
	end
end
