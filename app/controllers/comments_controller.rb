class CommentsController < ApplicationController
  before_filter :login_required, :except => :login

  def login
    session[:return_to] = url_for(:controller => 'guides', :action => 'show', :id => params[:id], :anchor => "comments")
    redirect_to :controller => 'account', :action => 'login'
  end

  def access_denied
    flash[:error] = 'you must login to do that'
    super
  end
 
  def create
    comment = Comment.new(params[:comment])
    comment.user = current_user

    if comment.save
      flash[:notice] = 'Comment added'
    else
      flash[:notice] = 'There was a problem adding your comment'
    end
    GuidePromoter.deliver_comment_notification(comment.guide, current_user)
    redirect_to :controller => 'guides', :action => 'show', :id => comment.guide
  end

  def destroy
    comment = Comment.find(params[:id])
    if comment.destroy
      flash[:notice] = 'yay'
    else
      flash[:notice] = 'error deleting comment'
    end
    redirect_to :controller => 'guides', :action => 'show', :id => comment.guide
  end
  
  def edit
    @comment = Comment.find(params[:id])
  end

  def update
    @comment = Comment.find(params[:id])
    if @comment.update_attributes(params[:comment])
      flash[:notice] = 'comment updated'
      redirect_to :controller => 'guides', :action => 'show', :id => @comment.guide.id
    else
      flash[:error] = 'comment could not be updated'
      render :action => 'edit'
    end
  end
      
end
