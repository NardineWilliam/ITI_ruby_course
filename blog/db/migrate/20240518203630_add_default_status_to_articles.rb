class AddDefaultStatusToArticles < ActiveRecord::Migration[7.1]
  def change
    change_column_default :articles, :status, 'public'
  end
end
