class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  #layout 'mailer'
end

# app/mailers/report_mailer.rb
class ReportMailer < ApplicationMailer
end
