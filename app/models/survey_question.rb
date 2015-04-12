class SurveyQuestion < ActiveRecord::Base



    has_many :survey_question_choices, :class_name => 'SurveyQuestionChoice'
    belongs_to :survey, :class_name => 'Survey', :foreign_key => :survey_id
    has_many :survey_responses, :class_name => 'SurveyResponse'
end
