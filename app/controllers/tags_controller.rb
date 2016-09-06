class TagsController < ApplicationController
	before_action :authenticate_user!
	def rate
		tag = Tag.find(params[:id])
		tag.score += params[:score].to_i
		tag.save
		if tag.score == 0
			tag.delete
		end
		redirect_to edit_image_url(tag.image_id)
	end
end
