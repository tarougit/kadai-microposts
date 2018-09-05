class LikesController < ApplicationController
  before_action :require_user_logged_in, only: [:create, :destroy]
  before_action :current_user, only: [:create, :destroy]
  
  def index
    if logged_in?
      @like_micropost = current_user.like_microposts.build
      @like_microposts = current_user.feed_like_microposts.order('created_at DESC').page(params[:page])
    end
  end
  
  def create
    like_micropost = Micropost.find(params[:micropost_id])
    current_user.like(like_micropost)
    flash[:success] = 'マイクロポストをお気に入りに入れました。'
    redirect_to current_user
  end

  def destroy
    like_micropost = Micropost.find(params[:micropost_id])
    current_user.unlike(like_micropost)
    flash[:success] = 'マイクロポストをお気に入りから外しました。'
    redirect_to current_user
  end
end
