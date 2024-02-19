class Match < ApplicationRecord
  has_and_belongs_to_many :users
  belongs_to :creator, :class_name => 'User', :foreign_key => :creator_id

  def to_param
    return self.id.to_s + '-' + self.title.parameterize 
  end
end
