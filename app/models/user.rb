class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :microposts
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  has_many :likes
  has_many :like_microposts, through: :likes, source: :micropost
#  has_many :reverses_of_like, class_name: 'Like', foreign_key: :'micropost_id'
#  has_many :like_microposts, through: :reverses_of_like, source: :user
  
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end
  
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end
  
  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
  def like(other_micropost)
#    unless self == other_user
      self.likes.find_or_create_by(micropost_id: other_micropost.id)
#    end
  end
  
  def unlike(other_micropost)
    like = self.likes.find_by(micropost_id: other_micropost.id)
    like.destroy if like
  end
  
  def liking?(other_micropost)
    self.like_microposts.include?(other_micropost)
  end
  
  def feed_like_microposts
    Like_micropost.where(micropost_id: self.liking_ids + [self.id])
  end
end
