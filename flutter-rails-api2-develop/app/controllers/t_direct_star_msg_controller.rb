class TDirectStarMsgController < ApplicationController
    def create
      #check unlogin user
      # checkuser
      @m_user = MUser.find_by(id: @current_user)
      if params[:s_user_id].nil?
        # redirect_to home_url
        render json: { error: 'User Message not found'}
      else
        @t_direct_star_msg = TDirectStarMsg.new
        @t_direct_star_msg.userid = @m_user.id
        @t_direct_star_msg.directmsgid = params[:id]
        @t_direct_star_msg.save
  
        @s_user = MUser.find_by(id: params[:s_user_id])
        # redirect_to @s_user
        render json: { success: 'star successful'}
      end
    end
  
    def destroy
      #check unlogin user
      # checkuser
      @m_user = MUser.find_by(id: @current_user)
      if params[:s_user_id].nil?
        # redirect_to home_url
      else
        TDirectStarMsg.find_by(directmsgid: params[:id], userid: @m_user.id).destroy
  
        @s_user = MUser.find_by(id: params[:s_user_id])
        render json: { success: 'star delete successful'}
      end
    end
  end