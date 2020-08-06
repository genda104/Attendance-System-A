class Hub < ApplicationRecord
  validates :hub_number, uniqueness: true, numericality: { :greater_than_or_equal_to => 0 }
  validates :name, presence: true
  validates :attendance, inclusion: { in:["出勤", "退勤"]}
end
