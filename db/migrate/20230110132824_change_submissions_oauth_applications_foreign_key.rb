class ChangeSubmissionsOauthApplicationsForeignKey < ActiveRecord::Migration[7.0]
  def up
    remove_foreign_key :submissions, :oauth_applications
    add_foreign_key :submissions, :oauth_applications, type: :uuid, on_delete: :nullify, index: true
  end

  def down
    remove_foreign_key :submissions, :oauth_applications
    add_foreign_key :submissions, :oauth_applications, type: :uuid, index: true
  end
end
