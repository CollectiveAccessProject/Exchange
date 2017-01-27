class ReportMailer < ApplicationMailer
	default from: 'exchange@collectiveaccess.org'
	layout "mailer"

	def report_email(email, report, r_title, r_id)
		@email = email
		@report = report
		@title = r_title
		@id = r_id
		perform_deliveries = true
		mail(to: 'michael@whirl-i-gig.com', subject: 'Report filed on' + @title)
	end
end
