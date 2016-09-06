class Image < ActiveRecord::Base
	mount_uploader :file, ImageUploader
	has_many :tags
end
