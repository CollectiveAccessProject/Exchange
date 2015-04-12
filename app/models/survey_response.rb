class SurveyResponse < ActiveRecord::Base



    belongs_to :survey_question_choice, :class_name => 'SurveyQuestionChoice', :foreign_key => :survey_question_choice_id
    belongs_to :survey_question, :class_name => 'SurveyQuestion', :foreign_key => :survey_question_id
    belongs_to :user, :class_name => 'User', :foreign_key => :user_id
end
