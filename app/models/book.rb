class Book < ApplicationRecord
  belongs_to :user
  update_index('users#user') { self }
end
