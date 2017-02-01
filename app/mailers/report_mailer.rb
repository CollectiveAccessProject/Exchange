class ReportMailer < ApplicationMailer
	default from: 'exchange@collectiveaccess.org'
	layout "mailer"
	
	attr_accessor :email, :r_user_name, :r_user_email
	
	def report_email(report, r_title, r_id, options = {})
		if options[:email]
			@reporter_email = options[:email]
			@reporter_name = ''
		else options[:r_user_name]
			@reporter_email = options[:r_user_email]
			@reporter_name = options[:r_user_name]
		end
		@report = report
		@title = r_title
		@id = r_id
		perform_deliveries = true
		mail(to: 'michael@whirl-i-gig.com', subject: 'Report filed on' + @title)
	end
end
