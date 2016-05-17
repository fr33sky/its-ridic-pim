class AddReportIdToAmazonStatements < ActiveRecord::Migration
  def change
    add_column :amazon_statements, :report_id, :integer
  end
end
