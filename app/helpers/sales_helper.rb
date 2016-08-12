module SalesHelper
  def product_name(sale)
    if sale.product.nil?
      sale.description
    else
      sale.product.name || sale.description
    end
  end
end
