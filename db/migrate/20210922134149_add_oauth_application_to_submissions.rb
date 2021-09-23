class AddOauthApplicationToSubmissions < ActiveRecord::Migration[6.1]
  def change
    add_reference :submissions, :oauth_application, foreign_key: true, type: :uuid
  end
end
