require 'carrierwave/orm/activerecord'

class UsersController <ApplicationController

	def index
		@users = User.all
	end

	def new
		@user = User.new
	end

	def create
		upload = User.create(params.require(:user).permit(:avatar))
		upload.save
	end

end