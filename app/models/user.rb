class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, :goal,  presence: true
  validates :nickname, length: { maximum: 6 }
  validates :labor_id, numericality: { other_than: 1, message: "can't be blank" }

  has_many :projects
  has_many :project_tasks
  has_many :tasks
  has_many :habits
  
end
