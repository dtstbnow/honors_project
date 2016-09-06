class ImagesController < ApplicationController
  before_action :authenticate_user!, except: [:index]
	def index
    if(params[:offset])
      offset = params[:offset].to_i
    else
      offset = 0
    end
		@images = Image.limit(5).offset(offset*5)
    @offset = offset
	end

  def search
    #Search for images by image and tag names
    name = params[:search]
    @images = Image.where("name like ?", "%"+name+"%")
    tags = Tag.where("name like ?", "%"+name+"%")
    for t in tags
       @images += Image.where(id: t.image_id)
     end
     @images.uniq!
     render :index
  end



	def new
		@image = Image.new
	end

	def create
    if(not params[:image][:file] or params[:image][:name] == "")
      flash[:alert] = "Missing fields"
      redirect_to images_new_url
    else
  		upload = Image.create(params.require(:image).permit(:file, :name))
  		upload.save
  		redirect_to images_url
    end
	end

  def edit
  	@image = Image.find(params[:id])
    begin
      @tags = @image.tags
    rescue
       @tags = []
     end
    x = Favorite.where(user_id: current_user.id, image_id:params[:id])
    if not x.empty?
      @rating = x[0].rating
    else
      @rating = 0
    end
  end

  def update
   	image = Image.find(params[:id])
   	new_tags = params[:tags]
    
    
    x = Favorite.where(user_id: current_user.id, image_id:image.id)
    if params[:commit] == "Like"
      if x.empty?
        fav = Favorite.create(image: image, rating: 1)
        current_user.favorites.append(fav)
      elsif x[0].rating != 1
        x[0].rating = 1
        x[0].save
      else
        x[0].delete
        x = []
      end
    elsif params[:commit] == "Dislike"
      if x.empty?
        fav = Favorite.create(image: image, rating: -1)
        current_user.favorites.append(fav)
      elsif x[0].rating != -1
        x[0].rating = -1
        x[0].save
      else
        x[0].delete
        x = []
      end
    end
    
   	new_tags = new_tags.split(",")
   	for t in new_tags
   		begin
        test = Tag.find(image_id: image.id, name:t)
        if test == nil
          tag = Tag.create!(name: t)
          tag.score = 1
         tag.save
         image.tags.push(tag)
       end
   		rescue
   		   tag = Tag.create!(name: t)
         tag.score = 1
         tag.save
         image.tags.push(tag)
   		end

   	end
    @tags = image.tags
    if not x.empty?
      @rating = x[0].rating
    else
      @rating = 0
    end
    @image = image
    render :edit
  end


end
