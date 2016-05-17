class RemoveReportIdFromAmazonStatements < ActiveRecord::Migration
  def change
    remove_column(:amazon_statements, :report_id)
  end
end
