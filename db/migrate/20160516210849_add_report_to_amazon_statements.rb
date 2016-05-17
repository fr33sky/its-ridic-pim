class AddReportToAmazonStatements < ActiveRecord::Migration
  def change
    add_column :amazon_statements, :report_id, :string
  end
end
