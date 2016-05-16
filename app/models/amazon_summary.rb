require 'peddler'
require 'dotenv'
require 'json'
require 'jsonpath'
require 'command_line_reporter'

# Allows you to query payment statements from Amazon
class AmazonSummary
  include CommandLineReporter
  attr_accessor :summary, :summary_as_array

  # Creates a new AmazonSummary for querying based on either a Hash representation
  # from peddler's MWS::Reports::Client.get_report(report_id) or a Fixnum representing
  # the XML report's ID from Amazon. When you provide the Fixnum (integer) version,
  # AmazonSummary uses peddler to retrieve the report.  The resulting object can be
  # used to retrieve specific data from the report for bookkeeping or other needs.
  # 
  # * *Args*  :
  #   - +report+ -> A Ruby Hash or Fixnum representing a payment statement from Amazon
  # * *Returns* :
  #   - An AmazonSummary object that can be queried for specific information
  def initialize(report)
    Dotenv.load
    case report
    when Fixnum
      client = MWS::Reports::Client.new(
        primary_marketplace_id: Credential.last.primary_marketplace_id,
        merchant_id: Credential.last.merchant_id,
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      )
      @summary_as_array = @summary = client.get_report(report).xml['AmazonEnvelope']['Message']['SettlementReport']
      @summary_as_array = process_hash(@summary_as_array)
    when Bignum
      client = MWS::Reports::Client.new(
        primary_marketplace_id: Credential.last.primary_marketplace_id,
        merchant_id: Credential.last.merchant_id,
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      )
      @summary_as_array = @summary = client.get_report(report).xml['AmazonEnvelope']['Message']['SettlementReport']
      @summary_as_array = process_hash(@summary_as_array)	  
    when Hash
      @summary_as_array = @summary = report
      @summary_as_array = process_hash(@summary_as_array)
    end
  end

  # The amount of tax for orders (not returns)
  # * *Returns* :
  #   - The total amount of tax on orders rounded to 2 decimal places
  def tax_orders
    JsonPath.on(@summary, '$..Item..ItemPrice..Component[?(@.Type=="Tax")]..Amount..__content__')
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  # The amount of tax for refunds (not orders)
  # * *Returns* :
  #   - The total amount of tax on refunds rounded to 2 decimal places
  def tax_refunds
    JsonPath.on(@summary, '$..ItemPriceAdjustments..Component[?(@.Type=="Tax")]..Amount..__content__')
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  # The total amount of tax for orders and refunds
  # * *Returns* :
  #   - tax_orders + tax_refunds rounded to 2 decimal places
  def total_tax
    (tax_orders.to_f + tax_refunds.to_f).round(2)
  end

  # The total dollar "amount" ordered for a particular SKU where the "amount-type" = ItemPrice
  # and the "amount-description" = Principal
  # * *Args* :
  #   - +sku+ -> The SKU for the ordered amount
  # * *Returns* :
  #   - A sum of the Principal amount (for ItemPrice) representing the total order amount for
  #     a particular SKU
  def order_amount(sku)
    JsonPath.on(@summary_as_array, "$..Item[?(@.SKU=='#{sku}')]..ItemPrice..[?(@.Type=='Principal')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  # The unique prices that a particular SKU was sold at.  Sometimes this is necessary when
  # trying to make bookkeeping software balance correctly (especially when the amounts end
  # up averaging to a fraction of a penny).
  # * *Args* :
  #   - +sku+ -> The SKU being queried for unique prices
  # * *Returns* :
  #   - An Array representing the unique prices an item was sold for
  def unique_prices(sku)
    prices = []
    item_data = JsonPath.on(@summary_as_array, "$..Item[?(@.SKU=='#{sku}')]")
    item_data.each do |id|
      qty    = get_quantity_from_item(id)
      amount = get_amount_from_item(id)
      price  = (amount / qty).to_f.round(2)
      prices << price
    end
    prices.uniq
  end

  # Determines of a particular SKU was sold at multiple prices
  # * *Args* :
  #   - +sku+ - The SKU being used to determine if it was sold at multiple prices
  # * *Returns* :
  #   - true if the item was sold at multiple prices and false if it was not
  def has_multiple_prices?(sku)
    uniq_prices = unique_prices(sku)
    return false if uniq_prices.class == NilClass ||  uniq_prices.empty?
    return true  if uniq_prices.size > 1
    return false if uniq_prices.size == 1
  end

  # When an item was sold at different prices (unique_prices) and (has_multiple_prices?),
  # this method allows you to provide the SKU and price to get the quantity sold at that
  # particular price
  # * *Args* :
  #   - +sku+ - The SKU in question
  #   - +price+ - The price sold at
  # * *Returns* :
  #   - The quantity of units sold at a particular price 
  def order_quantity_by_price(sku, price)
    total_quantity = 0
    items = JsonPath.on(@summary_as_array, "$..Item[?(@.SKU=='#{sku}')]")
    items.each do |item|
      qty  = get_quantity_from_item(item)
      amt  = get_amount_from_item(item)
      if (amt / qty).to_f.round(2) == price
        total_quantity += qty
      end
    end
    total_quantity.round(2)
  end

  # When an item was sold at different prices (unique_prices) and (has_multiple_prices?),
  # this method allows you to provide the SKU and price to get the amount sold at that
  # particular price
  # * *Args* :
  #   - +sku+ - The SKU in question
  #   - +price+ - The price sold at
  # * *Returns* :
  #   - The amount sold at a particular price
  def order_amount_by_price(sku, price)
    total_amount = 0
    items = JsonPath.on(@summary_as_array, "$..Item[?(@.SKU=='#{sku}')]")
    items.each do |item|
      qty  = get_quantity_from_item(item)
      amt  = get_amount_from_item(item)
      if (amt / qty).to_f.round(2) == price
        total_amount += amt
      end
    end
    total_amount.round(2)
  end

  # This helper method returns the quantity from the JsonPath expression "$..Item[?(@.SKU=='#{sku}')]"
  # where sku is the SKU provided from a parent method call
  # * *Args* :
  #   - +item+ -> The JsonPath Array that results from looking for all Items associated with a particular SKU
  # * *Returns* :
  #   - The Quantity of units from the +item+ argument
  def get_quantity_from_item(item)
    item['Quantity'].to_i
  end

  # This helper method is used to determine the amount sold for a particular
  # JsonPath expression in the form of "$..Item[?(@.SKU=='#{sku}')]"
  # * *Args* :
  #   - +item+ -> The JsonPath Array that results from looking for all Items associated with a particular SKU
  # * *Returns* :
  #   - The amount sold from the +item+ argument
  def get_amount_from_item(item)
    item['ItemPrice'][0]['Component'].reject { |i| i['Type'] != 'Principal' }[0]['Amount'][0]['__content__'].to_f
  end

  # The quantity sold by a particular SKU
  # * *Args* :
  #   - +sku+ -> The SKU in question
  # * *Returns* :
  #   - The quantity ordered given a particular +sku+
  def order_quantity(sku)
    JsonPath.on(@summary_as_array, "$..Item[?(@.SKU=='#{sku}')]..Quantity")
      .map(&:to_i).inject(:+).to_i
  end

  # The amount refunded given a particular SKU
  # * *Args* :
  #   - +sku+ -> The SKU in question
  # * *Returns* :
  #   - The amount refunded given a particular SKU
  def refund_amount(sku)
    JsonPath.on(@summary_as_array, "$..AdjustedItem[?(@.SKU=='#{sku}')]..ItemPriceAdjustments..Component[?(@.Type=='Principal')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  def refund_average_rate(sku)
    rar = JsonPath.on(@summary_as_array, "$..AdjustedItem[?(@.SKU=='#{sku}')]..ItemPriceAdjustments..Component[?(@.Type=='Principal')]..Amount..__content__")
      .map(&:to_f)
    if rar.size > 0
      average = (rar.inject(:+) / rar.size).to_f.round(2)
    else
      average = 0.00
    end
    average
  end

  # All of the SKUs represented in this particular payment statement
  # * *Returns* :
  #   - An Array representing all of the unique SKUs for this payment statement
  def skus
    JsonPath.on(@summary, '$..SKU').uniq!
  end

  # The median order price for a particular SKU.  The payment statement does not provide
  # the quantity of units for a return, so this can be useful to determine the rate at
  # which they were sold for.
  # * *Args* :
  #   - +sku+ -> The sku used to determine the median order price
  # * *Returns* :
  #   - The median order price given a particular SKU.
  def median_order_price(sku)
    mop = JsonPath.on(@summary_as_array, "$..Item[?(@.SKU=='#{sku}')]..ItemPrice..[?(@.Type=='Principal')]..Amount..__content__")
      .map(&:to_f)
    sorted = mop.sort
    len = sorted.length
    if sorted[0].nil?
      return -1
    end
    return (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0    
  end

  # The amount of shipping for orders
  # * *Returns* :
  #   - The amount of shipping charged for all orders
  def order_shipping
    JsonPath.on(@summary_as_array, '$..ItemPrice..Component[?(@.Type=="Shipping")]..Amount..__content__')
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  # The amount of shipping for refunds
  # * *Returns* :
  #   - The amount of shipping charged for all refunds
  def refund_shipping
    JsonPath.on(@summary_as_array, "$..ItemPriceAdjustments..Component[?(@.Type=='Shipping')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  # The amount of total shipping: order_shipping + refund_shipping
  # * *Returns*
  #   - order_shipping + refund_shipping
  def shipping_total
    (refund_shipping + order_shipping).to_f.round(2)
  end

  # The amount of promotion shipping (amount-type = 'Promotion' and amount-description = 'Shipping')
  # * *Returns* :
  #   - The total of promotion shipping
  def order_promotion_shipping
    JsonPath.on(@summary_as_array, "$..Promotion[?(@.Type=='Shipping')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  # The amount of promotion shipping from refunds
  # * *Returns* :
  #   - The total amount of promotion shipping from refunds
  def refund_promotion_shipping
    JsonPath.on(@summary_as_array, "$..PromotionAdjustment[?(@.Type=='Shipping')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  # order_promotion_shipping + refund_promotion_shipping
  # *  *Returns* :
  #    - order_promotion_shipping + refund_promotion_shipping
  def total_promotion_shipping
    (order_promotion_shipping + refund_promotion_shipping).round(2)
  end

  # The "GiftWrap" total
  # * *Returns* :
  #   - The total of "GiftWrap"
  def gift_wrap
    JsonPath.on(@summary_as_array, "$..ItemPrice..Component[?(@.Type=='GiftWrap')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  # The "ShippingTax" total (amount-type = ItemPrice and amount-description = ShippingTax)
  # * *Returns* :
  #   - The total ShippingTax
  def shipping_tax
    (JsonPath.on(@summary_as_array, "$..ItemPrice..Component[?(@.Type=='ShippingTax')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2) + 
    JsonPath.on(@summary_as_array, '$..ItemPriceAdjustments..Component[?(@.Type=="ShippingTax")]..Amount..__content__')
      .map(&:to_f).inject(:+).to_f.round(2)).round(2)
  end

  def promotion_amount(sku)
    JsonPath.on(@summary_as_array, "$..Item[?(@.SKU=='#{sku}')]..Promotion[?(@.Type=='Principal')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  # Determines the promotion "rate" using the most_common_value method
  # * *Args* :
  #   - +sku+ -> The SKU in question
  # * *Returns* :
  #   - The promotion rate computed using the most_common_rate method
  def promotion_rate(sku)
    pq = JsonPath.on(@summary_as_array, "$..Item[?(@.SKU=='#{sku}')]..Promotion[?(@.Type=='Principal')]..Amount..__content__")
      .map(&:to_f)
    if !(pq.empty?)
      most_common_value(pq)
    else
      0.00
    end
  end

  # transaction-type = Refund, amount-type = ItemPrice, amount-description = Goodwill
  # * *Returns* :
  #   - The "Goodwill" refund amount
  def goodwill(sku)
    JsonPath.on(@summary_as_array, "$..AdjustedItem[?(@.SKU=='#{sku}')]..ItemPriceAdjustments..Component[?(@.Type=='Goodwill')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  # transaction-type = other-transaction, amount-type = FBA Inventory Reimbursement, 
  # amount-description = MISSING_FROM_INBOUND, and a sum of the amount column.
  # * *Args* :
  #   - +sku+ -> The SKU in question
  # * *Returns* :
  #   - The total "MISSING_FROM_INBOUND" for the +sku+ provided
  def missing_from_inbound_amount(sku)
    JsonPath.on(@summary_as_array, "$..OtherTransaction[?(@.TransactionType=='MISSING_FROM_INBOUND')]..OtherTransactionItem[?(@.SKU=='#{sku}')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)    
  end

  # transaction-type = other-transaction, amount-type = FBA Inventory Reimbursement, 
  # amount-description = MISSING_FROM_INBOUND, and a sum of the quantity column
  # * *Args* :
  #   - +sku+ -> The SKU in question
  # * *Returns* :
  #   - A sum of the quantity for the given SKU (where amount-description = MISSING_FROM_INBOUND)
  def missing_from_inbound_quantity(sku)
    JsonPath.on(@summary_as_array, "$..OtherTransaction[?(@.TransactionType=='MISSING_FROM_INBOUND')]..OtherTransactionItem[?(@.SKU=='#{sku}')]..Quantity")
      .map(&:to_i).inject(:+).to_f.round(2)
  end

  # * *Returns* :
  #   - The total commission Amazon takes
  def amazon_commission
    json_path_expense('Commission')
  end

  # * *Returns*:
  #   - The total commission from Amazon for refunds
  def refund_commission
    JsonPath.on(@summary_as_array, "$..Fee[?(@.Type=='RefundCommission')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end
  
  def refund_commission_refund
    JsonPath.on(@summary_as_array, "$..ItemFeeAdjustments..Fee[?(@.Type=='Commission')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  def refund_commission_total
    (refund_commission + refund_commission_refund).round(2)
  end
  
  # Returns the sum of the FBAPerOrderFulfillmentFee marked as an expense
  # * *Returns* :
  #   - A sum of the expenses marked as FBAPerOrderFulfillmentFee
  def fba_per_order_fulfillment_fee
    json_path_expense('FBAPerOrderFulfillmentFee')
  end
  
  # Returns the sum of the FBAPerUnitFulfillmentFee marked as an expense
  # * *Returns* :
  #   - A sum of the expenses marked as FBAPerUnitFulfillmentFee
  def fba_per_unit_fulfillment_fee
    json_path_expense('FBAPerUnitFulfillmentFee')
  end
  
  # Returns the sum of the FBAWeightBasedFee marked as an expense
  # * *Returns* :
  #   - A sum of the expenses marked as FBAWeightBasedFee
  def fba_weight_based_fee
    json_path_expense('FBAWeightBasedFee')
  end
  
  # Returns the sum of the SalesTaxServiceFee marked as an expense
  # * *Returns* :
  #   - A sum of the expenses marked as SalesTaxServiceFee
  def sales_tax_service_fee
    json_path_expense('SalesTaxServiceFee')
  end
  
  # Returns a sum of the Fee Type 'Inbound Transportation Fee'
  # * *Returns* :
  #   - A sum of all fees with type 'Inbound Transportation Fee'
  def inbound_transportation_fee
    JsonPath.on(@summary_as_array, "$..Fees..Fee[?(@.Type=='Inbound Transportation Fee')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  # Returns the sum of the ShippingChargeback marked as an expense
  # * *Returns* :
  #   - A sum of the expenses marked as ShippingChargeback
  def shipping_chargeback
    json_path_expense('ShippingChargeback')
  end
  
  # Returns the ShippingChargebackRefund
  # * *Returns* :
  #   - A sum of the ShippingChargebackRefund
  def shipping_chargeback_refund
    JsonPath.on(@summary_as_array, "$..AdjustedItem..ItemFeeAdjustments..Fee[?(@.Type=='ShippingChargeback')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end
  
  # Returns the fee type 'FBA Customer Return Per Order Fee'
  # * *Returns* :
  #   - A sum of the fee type 'FBA Customer Return Per Order Fee'
  def fba_customer_return_per_order_fee
    JsonPath.on(@summary_as_array, "$..Fees..Fee[?(@.Type=='FBA Customer Return Per Order Fee')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end
  
  # Returns the fee type 'FBA Customer Return Per Unit Fee'
  # * *Returns* :
  #   - A sum of the fee type 'FBA Customer Returns Per Unit Fee'
  def fba_customer_return_per_unit_fee
    JsonPath.on(@summary_as_array, "$..Fees..Fee[?(@.Type=='FBA Customer Return Per Unit Fee')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)    
  end
  
  # Returns the fee type 'FBA Customer Return Weight Based Fee'
  # * *Returns* :
  #   - A sum of the fee type 'FBA Customer Return Weight Based Fee'
  def fba_customer_return_weight_based_fee
    JsonPath.on(@summary_as_array, "$..Fees..Fee[?(@.Type=='FBA Customer Return Weight Based Fee')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)    
  end
  
  # Returns the GiftwrapChargeback
  # * *Returns* :
  #   - A sum of expense GiftwrapChargeback
  def gift_wrap_charge_back
    json_path_expense('GiftwrapChargeback')
  end

  def payable_to_amazon
    JsonPath.on(@summary_as_array, "$..OtherTransaction[?(@.TransactionType=='Subscription Fee')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  def storage_fees
    JsonPath.on(@summary_as_array, "$..OtherTransaction[?(@.TransactionType=='Storage Fee')]..Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  def warehouse_damage
    JsonPath.on(@summary_as_array, "$..OtherTransaction[?(@.TransactionType=='WAREHOUSE_DAMAGE')].Amount..__content__")    
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  def warehouse_damage_exception
    JsonPath.on(@summary_as_array, "$..OtherTransaction[?(@.TransactionType=='WAREHOUSE_DAMAGE_EXCEPTION')].Amount..__content__")    
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  def warehouse_lost_manual
    JsonPath.on(@summary_as_array, "$..OtherTransaction[?(@.TransactionType=='WAREHOUSE_LOST_MANUAL')].Amount..__content__")    
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  def disposal_fee
    JsonPath.on(@summary_as_array, "$..[?(@.TransactionType=='DisposalComplete')].Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end
  
  def reversal_reimbursement
    JsonPath.on(@summary_as_array, "$..[?(@.TransactionType=='REVERSAL_REIMBURSEMENT')].Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end
  
  def cs_error_items
    JsonPath.on(@summary_as_array, "$..[?(@.TransactionType=='CS_ERROR_ITEMS')].Amount..__content__")
      .map(&:to_f).inject(:+).to_f.round(2)
  end

  def create_sales_receipt
    sales_receipt_methods = [:total_tax, :shipping_total, :total_promotion_shipping, :shipping_tax, :gift_wrap]
    descriptions = {
      "3U-6S08-R6CZ"     => "It's Ridic! Warm touchscreen / texting winter gloves - Black",
      "8A-OK9F-9LI8"     => "It's Ridic! Warm touchscreen / texting winter gloves - White",
      "1V-Y2BK-UYT2"     => "It's Ridic! Record Stall Metal Filled 2-panel Hacky Sack",
      "635833403782"     => "It's Ridic! Spiral Pellet Filled 32-panel Hacky Sack Footbag",
      "635833403799"     => "It's Ridic! Record-breaker sand filled 2-panel Hacky Sack",
      "HX-V5LI-NAGX"     => "It's Ridic! Round Stall Sand Filled 32-panel Hacky Sack",
      "5M-E4RR-K4EB"     => "It's Ridic! Round Pop Pellet Filled 2-panel Hacky Sack Footbag",
      "Magflash-Silver"  => "IT'S RIDIC! SILVER Extendible Magnetic LED Flashlight Pickup Tool",
      "Magflash-Black"   => "IT'S RIDIC! BLACK Extendible Magnetic LED Flashlight Pickup Tool",
      "Magflash-Blue"    => "IT'S RIDIC! BLUE Extendible Magnetic LED Flashlight Pickup Tool",
      "Magflash-Red"     => "IT'S RIDIC! RED Extendible Magnetic LED Flashlight Pickup Tool",
      "YogaSock-Black"   => "IT'S RIDIC! Women 100% Pure Cotton Yoga Sock Black",
      "YogaSock-Green"   => "IT'S RIDIC! Women 100% Pure Cotton Yoga Sock Green",
      "YogaSock-Pink"    => "IT'S RIDIC! Women 100% Pure Cotton Yoga Sock Pink",
      "YogaSock-Purple"  => "IT'S RIDIC! Women 100% Pure Cotton Yoga Sock Purple"
    }
  end
  
  def sales_receipt_report
    puts "Report is loading please wait..."
    sales_receipt_methods = [:total_tax, :shipping_total, :total_promotion_shipping, :shipping_tax, :gift_wrap]
    descriptions = {
      "3U-6S08-R6CZ"     => "It's Ridic! Warm touchscreen / texting winter gloves - Black",
      "8A-OK9F-9LI8"     => "It's Ridic! Warm touchscreen / texting winter gloves - White",
      "1V-Y2BK-UYT2"     => "It's Ridic! Record Stall Metal Filled 2-panel Hacky Sack",
      "635833403782"     => "It's Ridic! Spiral Pellet Filled 32-panel Hacky Sack Footbag",
      "635833403799"     => "It's Ridic! Record-breaker sand filled 2-panel Hacky Sack",
      "HX-V5LI-NAGX"     => "It's Ridic! Round Stall Sand Filled 32-panel Hacky Sack",
      "5M-E4RR-K4EB"     => "It's Ridic! Round Pop Pellet Filled 2-panel Hacky Sack Footbag",
      "Magflash-Silver"  => "IT'S RIDIC! SILVER Extendible Magnetic LED Flashlight Pickup Tool",
      "Magflash-Black"   => "IT'S RIDIC! BLACK Extendible Magnetic LED Flashlight Pickup Tool",
      "Magflash-Blue"    => "IT'S RIDIC! BLUE Extendible Magnetic LED Flashlight Pickup Tool",
      "Magflash-Red"     => "IT'S RIDIC! RED Extendible Magnetic LED Flashlight Pickup Tool",
      "YogaSock-Black"   => "IT'S RIDIC! Women 100% Pure Cotton Yoga Sock Black",
      "YogaSock-Green"   => "IT'S RIDIC! Women 100% Pure Cotton Yoga Sock Green",
      "YogaSock-Pink"    => "IT'S RIDIC! Women 100% Pure Cotton Yoga Sock Pink",
      "YogaSock-Purple"  => "IT'S RIDIC! Women 100% Pure Cotton Yoga Sock Purple"
    }
    count = 0
    table :border => true do
      row :color => 'red' do
        column '#', :width => 2
        column 'PRODUCT', :width => 18
        column 'DESCRIPTION', :width => 72
        column 'QTY', :width => 5
        column 'RATE', :width => 6
        column 'AMOUNT', :width => 10
      end    
      self.skus.sort.each do |sku|
        if has_multiple_prices?(sku)
          prices = unique_prices(sku)
          prices.each do |price|
            order_qty = self.order_quantity_by_price(sku, price)
            order_amt = self.order_amount_by_price(sku, price)
            order_rate = (order_amt / order_qty).to_f.round(2) if order_qty != 0
            refund_amt  = self.refund_amount(sku)
            refund_rate = median_order_price(sku)
            refund_qty  = (refund_amt / refund_rate).to_f.round(2) if refund_rate != 0
            disc_amt    = self.promotion_amount(sku)
            disc_rate   = self.promotion_rate(sku)
            disc_qty    = (disc_amt / disc_rate).to_f.round(2) if disc_rate != 0
            description = descriptions[sku] ||= sku
            if order_qty != 0
              row :color => 'green', :bold => true do
                column count += 1
                column sku
                column description
                column order_qty.to_i
                column order_rate
                column order_amt
              end
            end       
            if refund_qty != 0
              row :color => 'green', :bold => true do
                column count += 1
                column sku
                column "REFUND - #{description}"
                column refund_qty.to_i
                column refund_rate
                column refund_amt
              end
            end
            if disc_rate != 0
              row :color => 'green', :bold => true do
                column count += 1
                column sku
                column "DISCOUNT - #{description}"
                column disc_qty.to_i
                column disc_rate
                column disc_amt
              end
            end            
          end
        else
          order_qty   = self.order_quantity(sku)
          order_amt   = self.order_amount(sku)
          order_rate  = (order_amt / order_qty).to_f.round(2) if order_qty != 0
          refund_amt  = self.refund_amount(sku)
          refund_rate = median_order_price(sku)
          refund_qty  = (refund_amt / refund_rate).to_f.round(2) if refund_rate != 0
          disc_amt    = self.promotion_amount(sku)
          disc_rate   = self.promotion_rate(sku)
          disc_qty    = (disc_amt / disc_rate).to_f.round(2) if disc_rate != 0
          description = descriptions[sku] ||= sku
          goodwillamt = self.goodwill(sku)
          mfi_amt     = self.missing_from_inbound_amount(sku)
          mfi_qty     = self.missing_from_inbound_quantity(sku)
          mfi_rate    = (mfi_amt / mfi_qty).to_f.round(2) if mfi_qty != 0
          if order_qty != 0
            row :color => 'green', :bold => true do
              column count += 1
              column sku
              column description
              column order_qty.to_i
              column order_rate
              column order_amt
            end
          end       
          if refund_qty != 0
            row :color => 'green', :bold => true do
              column count += 1
              column sku
              column "REFUND - #{description}"
              column refund_qty.to_i
              column refund_rate
              column refund_amt
            end
          end
          if disc_rate != 0
            row :color => 'green', :bold => true do
              column count += 1
              column sku
              column "DISCOUNT - #{description}"
              column disc_qty.to_i
              column disc_rate
              column disc_amt
            end
          end
          if goodwillamt != 0
            row :color => 'green', :bold => true do
              column count += 1
              column sku
              column "Goodwill - #{description}"
              column 1
              column goodwillamt
              column goodwillamt
            end
          end
          if mfi_qty != 0
            row :color => 'green', :bold => true do
              column count += 1
              column sku
              column "MISSING_FROM_INBOUND - #{description}"
              column mfi_qty.to_i
              column mfi_rate
              column mfi_amt
            end
          end
        end
      end
      sales_receipt_methods.each do |m|
        product = case m.to_s
                    when "total_tax" then "Sales Tax"
                    when "shipping_total" then "Shipping"
                    when "total_promotion_shipping" then "PromotionShipping"
                    when "shipping_sales_tax" then "ShippingSalesTax"
                    when "gift_wrap" then "FBAGiftWrap"
                  else m.to_s
                  end
        amount = self.send(m)
        qty = 1
        qty = -1 if product == "PromotionShipping"
        rate = amount * qty
        row :color => 'green', :bold => true do
          column count += 1
          column product
          column ""
          column qty
          column rate
          column amount
        end        
      end
    end
  end

  def expense_report(description)
    expense_methods = [:amazon_commission, :refund_commission_total, 
                      :fba_per_order_fulfillment_fee, :fba_per_unit_fulfillment_fee, 
                      :fba_weight_based_fee, :sales_tax_service_fee, :inbound_transportation_fee,
                      :payable_to_amazon, :storage_fees, :shipping_chargeback, 
                      :shipping_chargeback_refund, :warehouse_damage, 
                      :warehouse_damage_exception, :warehouse_lost_manual,
                      :fba_customer_return_per_order_fee, :fba_customer_return_per_unit_fee, 
                      :fba_customer_return_weight_based_fee, :gift_wrap_charge_back,
					  :disposal_fee, :reversal_reimbursement, :cs_error_items]
    table :border => true do
      row :color => 'red' do
        column '#', :width => 2
        column 'ACCOUNT', :width => 35
        column 'DESCRIPTION', :width => 30
        column 'AMOUNT', :width => 10
      end
      expense_methods.each_with_index do |method, index|
        account = case method.to_s.camelcase
                  when "RefundCommissionTotal" then "AmazonRefundCommission"
                  when "SalesTaxServiceFee" then "AmazonSalesTaxServiceFee"
                  when "InboundTransportationFee" then "FBAInboundTransportationFee"
                  when "PayableToAmazon" then "Amazon Monthly FBA FEE"
                  when "StorageFees" then "FBAStorageFee"
                  when "WarehouseDamage" then "DamagedInventory"
                  when "GiftWrapChargeBack" then "FBAGiftWrapchargeback"
                  else method.to_s.camelcase.gsub('Fba', 'FBA')
        end
        row :color => 'green', :bold => true do
          column index + 1
          column account
          column "#{description}"
          column self.send(method) *-1
        end
      end
    end
  end

  private
    # Helper Methods
    def json_path(string, float = true)
      if float
        JsonPath.on(@summary_as_array, string).map(&:to_f).inject(:+).to_f.round(2)
      else
        JsonPath.on(@summary_as_array, string).map(&:to_i).inject(:+).to_f.round(2)
      end
    end

    def json_path_expense(string)
      json_path("$..ItemFees..Fee[?(@.Type=='#{string}')]..Amount..__content__")
    end

    # Returns the most common element in an Array
    def most_common_value(a)
      if a.empty?
        return 0
      end
      if a.class == Array
        a.group_by do |e|
          e
        end.values.max_by(&:size).first
      elsif a.class == String
        a = JsonPath.on(@summary_as_array, '$..ItemPriceAdjustments..Component[?(@.Type=="Tax")]..Amount..__content__').map(&:to_f)
        most_common_value(a)
      end
    end

    def print_line(char = "-")
      puts char * 40
    end

    def process_hash(hash)
      hash.each do |k,v|
        if v.class == Hash
          hash[k] = [] << process_hash(v)
        elsif v.class == Array
          v.each do |v2|
            if v2.class == Hash
              v2 = [] << process_hash(v2)
            end
          end
        end
      end
     end
end


