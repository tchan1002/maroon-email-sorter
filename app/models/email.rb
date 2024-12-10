# == Schema Information
#
# Table name: emails
#
#  id           :bigint           not null, primary key
#  body         :text
#  pitch        :string
#  pitch_status :string
#  sender       :string
#  subject      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :integer
#
class Email < ApplicationRecord
belongs_to :user, required: true, class_name: "User", foreign_key: "user_id", counter_cache: true
end
