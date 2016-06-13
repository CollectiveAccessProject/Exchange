module RankModel
  extend ActiveSupport::Concern

  private


  def set_rank
    self.rank = self.id
    self.save
  end
end