class AddPitchToEmails < ActiveRecord::Migration[7.1]
  def change
    add_column :emails, :pitch, :string
  end
end
