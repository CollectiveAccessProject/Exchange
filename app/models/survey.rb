class Survey < ActiveRecord::Base



    has_many :survey_questions, :class_name => 'SurveyQuestion'
    belongs_to :resource, :class_name => 'Resource', :foreign_key => :resource_id
end
