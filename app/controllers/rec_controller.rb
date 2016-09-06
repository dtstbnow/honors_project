class RecController < ApplicationController
	before_action :authenticate_user!

	def history
		@images = current_user.favorites.where(rating: 1)
		render :history
	end

	def index
		rankings = Hash.new
		#Loops through the user's favorited images and creates a hash with the tags names and their score.
		tags = []
		for x in current_user.favorites
			for y in x.image.tags
				if not rankings[y.name]
					rankings[y.name] = y.score
					tags.append(y.name)
				else
					rankings[y.name] += y.score
				end
			end
		end
		

		window_size =[5, tags.size].min#The number of tags we are looking for at a time
		res = []
		score_map = {}
		while window_size >0  #Score map is a combination of tags and their scores.  This part could be improved by putting a stricter cap on the number of loops, as it can run quite often, combining it with the actual db query and getting it to run until it retuns x results
			for combination in tags.combination(window_size)
				combination.to_set
				if not score_map[combination]
					score = 0
					for r in combination
						score += rankings[r]
					end
					score_map[combination] = score
				end
			end
			window_size -=1
		end
		score_map = Hash[score_map.sort_by{|k, score| -score}]
		

		seen = []
		score_map.each{|element,score|
			result = calculate_reccomendations(element)
			for r in result
				if not seen.include? r.name
					res.append(r)
					seen.append(r.name)
				end

				if res.length > 5
					break
				end
			end

		}
		@images = res
	end

	def sorter(input)
		output = []
		input = input.sort_by{|k, score| score}
		input.each{ |k, v| output.append(k)}
		return output

	end

	def calculate_reccomendations(tags)
		##Returns all images that contain all of the tags that are passed in
		t = Tag.where(name: tags.flatten)
		favorites = []
		for el in current_user.favorites
			if el.rating == 1 #1 means the user favorited the images as opposed to -1
				favorites.append(el.image_id)
			end
		end
		t = t.sort_by{|q| q.name}
		final = false#final = array of image id's
		last_seen = []#Array of image id's that contain the last tag
		name = false#Name of the current working tag
		t.delete_if{|el| favorites.include?(el.image_id)}#We don't want to reccomend an image the user alread favorited
		for tag in t
			if not final#First tag we are looping through
				if not name#this is only used the first loop 
					name = tag.name
					last_seen = [tag.image_id]
				elsif tag.name != name#We are changing tags, assign final to all the id's we have found so far, we only remove from final, never add to it
					final = last_seen
					last_seen = [tag.image_id]
					name = tag.name
				else
					last_seen.append(tag.image_id)
				end
			elsif tag.name != name#We have final, and are switching tags again
				final.delete_if{|el| not last_seen.include?(el)}#Remove from final any id's that we didn't see in the last tag
				name = tag.name
				last_seen = [tag.image_id]
			else
				last_seen.append(tag.image_id)
			end
		end
		if not final#edge case, if we are only passed in one tag
			if not last_seen
				return []
			else
				final = last_seen
			end
		else

			final.delete_if{|el| not last_seen.include?(el)}
		end
		res = Image.where(id: final)
		res = res.uniq#remove any duplicate images
		return res
	end


end