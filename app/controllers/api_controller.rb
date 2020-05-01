class ApiController < ApplicationController
	def initialize
		@@api_version = 1.0
		@@types = ["collection_objects", "resources", "collections"]
		@@search_fields = [
			"id", "resource_type", "slug", "title", "subtitle", "copyright_license", "access", 
			"created_at", "updated_at", "body_text", "author_name", "collecton_identifier"
		]
		@@detail_fields = [
			"id", "resource_type", "slug", "title", "subtitle", "copyright_license", "copyright_notes", "access", 
			"created_at", "updated_at", "body_text", "author_name", "collecton_identifier", 
			"in_response_to_resource_id", "forked_from_resource_id", "on_display", "artist", 
			"location", "start_date", "end_date", "classification", "additional_classification", 
			"medium", "support", "style", "artist_nationality", "subject_matter", "keywords"
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
					result_data = ApiController.rewrite_field_values(r._source.to_hash.select {|key, value| @@search_fields.include?(key) })
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
			filtered_data = ApiController.rewrite_field_values(r.attributes.select {|key, value| @@detail_fields.include?(key) })
			
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
	
	def self.rewrite_field_values(result_data)
		# Rewrite type as text
		result_data['type'] = Resource.resource_type_as_text(result_data['resource_type'])
		result_data.delete('resource_type')

		# Rewrite copyright_license as text
		result_data['copyright_license'] = Resource.get_license_type_as_text(result_data['copyright_license'])

		# Explode keywords into list
		result_data['keywords'] = result_data['keywords'].split(/\|/).reject { |i| i.empty? }  if result_data['keywords'] != nil
		
		result_data
	end
end
