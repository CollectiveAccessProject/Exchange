class ApiController < ApplicationController
	def initialize
		@@api_version = 1.0
		@@types = ["collection_objects", "resources", "collections"]
		@@search_fields = [
			"id", "resource_type", "slug", "title", "subtitle", "physical_description", "copyright_license", "access", 
			"created_at", "updated_at", "body_text", "author_name", "collection_identifier", "date_display"
		]
		@@detail_fields = [
			"id", "resource_type", "slug", "title", "collection_identifier", "subtitle", "physical_description", "copyright_license", "copyright_notes", "access", 
			"created_at", "updated_at", "body_text", "author_name", "credit_line", 
			"in_response_to_resource_id", "forked_from_resource_id", "on_display", "artist", "artist_gender", "artist_nationality",
			"location", "start_date", "end_date", "date_display", "classification", "additional_classification", 
			"medium", "support", "medium_and_support_display", "style", "subject_matter", "keywords", "cover_caption", "cover_alt_text"
		]
	end

	def search
		params.permit(:query, :q, :page, :type, :length, :sort, refine: [])
		
		t = params[:type]
		t = "resources" if !@@types.include? t
		
		l = params[:length]
		l = 10 if l.nil?		
		begin
			l = l.to_i
		rescue
			l = 10
		end
		
		p = params[:page]
		begin
			p = p.to_i
		rescue
			p = 0
		end
		
		begin
			# Do search
			res = Resource::quicksearch(params[:q], {models: true, page: p, length: l, type: t, sort: params[:sort],  user: current_user, singleResultSet: true})
			if res.nil?
			
			end
			total = res.response.results.total
		
			# Filter fields
			filtered_results = [] 
		
			c = 0
			catch :end_of_page do			
				results = res.response
		
				for r in results 
					result_data = ApiController.rewrite_field_values(r, r._source.to_hash.select {|key, value| @@search_fields.include?(key) }, :search)
					filtered_results.append(result_data)
			
					c = c + 1
					throw :end_of_page if l != nil and c >= l
				end
			end
		rescue => e
			render json: ApiController.render_error(e)
			return
		end
		render json: ApiController.render_response({
			"length": filtered_results.length,
			"num_hits": total,
			"results": filtered_results
		})
	end
	
	def detail
		params.permit(:type, :id)
		
		begin
			# Is ID key or accession #?
			r = Resource.find(params[:id].to_i)
		
			# Check access to record	
			if !r.can(:view, current_user)
				raise "Cannot load resource"
			end
		
			# Filter fields
			filtered_data = ApiController.rewrite_field_values(r, r.attributes.select {|key, value| @@detail_fields.include?(key) }, :detail)
			
		rescue => e
			render json: ApiController.render_error(e)
			return
		end
		
		render json: ApiController.render_response({"data": filtered_data})
	end
	
	def self.render_response(data)
		r = {
			"api_version": @@api_version,
			"generated": Time.now.iso8601
		}
		r.merge(data)
	end
	
	def self.render_error(e)
		self.render_response({ "error": e.message })
	end
	
	def self.rewrite_field_values(r, result_data, type=nil)
		# Rewrite type as text
		result_data['type'] = Resource.resource_type_as_text(result_data['resource_type'])
		result_data.delete('resource_type')

		# Rewrite copyright_license as text
		result_data['copyright_license'] = Resource.get_license_type_as_text(result_data['copyright_license'])

		# Explode keywords into list
		result_data['keywords'] = result_data['keywords'].split(/\|/).reject { |i| i.empty? }  if result_data['keywords'] != nil
		
		result_data['link'] = absolute_url_for_resource(result_data['id'])
		
		# Media
		result_data['media'] = []
		
		# Convert to resource instance if needed (detail view passes resource instance, search results need conversion)
		# Everything from here on in requires an instance
		r = Resource.find(r.id) if !r.respond_to? "media_files"
		r.media_files.each do |m|
			result_data['media'].append({
				id: m.id,
				url: absolute_url_for_media(m),
				caption: m.caption,
				alt_text: m.alt_text
			})
		end
		
		if r.cover and r.cover.url
			result_data['cover'] = absolute_url_for_media(r, 'cover')
		elsif result_data['media'].length > 0 and result_data['media'][0]
			result_data['cover'] = result_data['media'][0][:url]
			result_data['cover_caption'] = result_data['media'][0][:caption]
			result_data['cover_alt_text'] = result_data['media'][0][:alt_text]
		else
			result_data['cover'] = nil
			result_data['cover_caption'] = nil
			result_data['cover_alt_text'] = nil
		end
		
		
		
		# Add role (aka audience) names for roles directly linked to resource
		result_data['audiences'] = r.roles.map { |x|  x['name'] }
	
		# Add role names related to resource author
		
		# Add author name is not populated
		if !r.author_name.nil?
			result_data['author_name'] = r.author_name
			result_data['author_roles'] = User.find(r.author_id).roles.map { |x|  x['name'] } if !r.author_id.nil?
		elsif !r.author_id.nil?
			u = User.find(r.author_id).roles.map { |x|  x['name'] } 
			result_data['author_name'] = u.name
			result_data['author_roles'] = u.roles.map { |x|  x['name'] }
		elsif !r.user_id.nil?
			u = User.find(r.user_id)
			result_data['author_name'] = u.name
			result_data['author_roles'] = u.roles.map { |x|  x['name'] }
		end 
	
		# Related resources
		result_data['related'] = r.related_resources.map { |x|  
			rel = (x.resource.id == r.id) ? x.related : x.resource
			{id: rel.id, title: rel.title, link: absolute_url_for_resource(rel.id) } 
		} if !r.related_resources.nil? and (type == :detail)
	
		# Related collections
		result_data['collections'] = r.parents.map { |x|  
			m = []
			x.children.each do |c| 
				c.media_files.each do |mf|
					m.append({
						id: mf.id,
						url: absolute_url_for_media(mf),
						caption: mf.caption,
						alt_text: mf.alt_text
					})
				end
			end
			{id: x.id, title: x.title, link: absolute_url_for_resource(x.id), media: m } 
		} if !r.parents.nil? and (type == :detail)
		result_data
	end
	
	def self.absolute_url_for_resource(resource_id)
		return '' if resource_id.nil?
		
		hostinfo = Rails.application.config.x.absolute_url_options
		return hostinfo[:protocol] + '://' + hostinfo[:host] + '/resources/' + resource_id.to_s
	end
	
	def self.absolute_url_for_media(m, f='thumbnail')
		return '' if m.nil?
		
		hostinfo = Rails.application.config.x.absolute_url_options
		return hostinfo[:protocol] + '://' + hostinfo[:host] + m.send(f).url
	end
end
