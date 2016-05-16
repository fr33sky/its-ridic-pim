module SalesHelper
  def product_name(sale)
    if sale.product.nil?
      sale.description
    else
      sale.description || sale.product.name
    end
  end
end
