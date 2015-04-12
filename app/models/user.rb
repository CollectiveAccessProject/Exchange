class User < ActiveRecord::Base



    has_many :change_logs, :class_name => 'ChangeLog'
    has_many :comments, :class_name => 'Comment'
    has_many :resource_accesses, :class_name => 'ResourceAccess'
    has_many :resources, :class_name => 'Resource'
    has_many :survey_responses, :class_name => 'SurveyResponse'
    has_many :tags, :class_name => 'Tag'
    has_many :user_feedbacks, :class_name => 'UserFeedback'
    has_many :user_group_memberships, :class_name => 'UserGroupMembership'
end
