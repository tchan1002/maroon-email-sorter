class CreateEmails < ActiveRecord::Migration[7.1]
  def change
    create_table :emails do |t|
      t.integer :user_id
      t.string :subject
      t.text :body
      t.string :sender
      t.string :pitch_status

      t.timestamps
    end
  end
end
