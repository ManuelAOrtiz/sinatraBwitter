class Blog < ActiveRecord::Base
	belongs_to :user
	has_many :comments
end

class User < ActiveRecord::Base
	has_many :blogs
	has_many :comments
end

class Comment < ActiveRecord::Base
	belongs_to :user
	belongs_to :blogs
end