class BackfillUserForExistingArticles < ActiveRecord::Migration[7.1]
  def up
    default_user = User.find_by(email: 'user@gmail.com')
    Article.where(user_id: nil).update_all(user_id: default_user.id) if default_user
  end

  def down
  end
end
