class SurveyQuestionChoice < ActiveRecord::Base


    self.inheritance_column = :ruby_type
    belongs_to :survey_question, :class_name => 'SurveyQuestion', :foreign_key => :survey_question_id
    has_many :survey_responses, :class_name => 'SurveyResponse'
end
