class User < ApplicationRecord
  has_many :books

  update_index('users#user') { users }
end
