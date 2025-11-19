class Labor < ActiveHash::Base
  self.data = [
    { id: 1, name: '---' },
    { id: 2, name: '小学生' },
    { id: 3, name: '中学生' },
    { id: 4, name: '高校生' },
    { id: 5, name: '大学生' },
    { id: 6, name: '正社員' },
    { id: 7, name: 'アルバイト' },
    { id: 8, name: 'パート' },
    { id: 9, name: '契約社員' },
    { id: 10, name: '派遣社員' }
  ]

  include ActiveHash::Associations
  has_many :users
 
end