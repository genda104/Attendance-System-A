class Base < ApplicationRecord
  validates :base_id, presence: true, uniqueness: true, numericality: { only_integer: true }
  validates :name, presence: true
end
