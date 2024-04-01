class ChannelUserController < ApplicationController
 
  def create
    #check unlogin user
    # checkuser
    if params[:channel_id].nil?
      render json: @t_user_channel.errors, status: :unprocessable_entity
    elsif MChannel.find_by(id:params[:channel_id]).nil?
      render json: @t_user_channel.errors, status: :unprocessable_entity
    else
      @t_user_channel = TUserChannel.new
      @t_user_channel.message_count = 0
      @t_user_channel.unread_channel_message = 0
      @t_user_channel.created_admin = 0
      @t_user_channel.userid = params[:user_id]
      @t_user_channel.channelid = params[:channel_id]
      @t_user_channel.save
      # render json: @t_user_channel, status: :unprocessable_entity
       render json: { message: "Successful" }, status: :ok
    end
  end
  
  def destroy
    #check unlogin user
    # checkuser
    if params[:channel_id].nil?
      render json: @t_user_channel.errors, status: :unprocessable_entity
    elsif MChannel.find_by(id: params[:channel_id]).nil?
      render json: @t_user_channel.errors, status: :unprocessable_entity
    else
      TUserChannel.find_by(userid: params[:id], channelid: params[:channel_id]).destroy
      render json: { message: "Successful Delete" }, status: :ok
    end
  end

  def join
    #check unlogin user
    # checkuser

    if params[:channel_id].nil?
      render json: @t_user_channel.errors, status: :unprocessable_entity
    elsif MChannel.find_by(id: params[:channel_id]).nil?
      render json: @t_user_channel.errors, status: :unprocessable_entity
    else
      @t_user_channel = TUserChannel.new
      @t_user_channel.message_count = 0
      @t_user_channel.unread_channel_message = 0
      @t_user_channel.created_admin = 0
      @t_user_channel.userid = params[:userid]
      @t_user_channel.channelid = params[:channel_id]
      @t_user_channel.save 
      @m_channel = MChannel.find_by(id: params[:channel_id])
      render json: { message: "Successful Join" }, status: :ok
    end
  end

  def show
    #check unlogin user
    # checkuser
    if params[:channel_id].nil?
      render json: @t_user_channel.errors, status: :unprocessable_entity
    elsif MChannel.find_by(id: params[:channel_id]).nil?
      render json: @t_user_channel.errors, status: :unprocessable_entity
    else
      @w_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id")
                      .where("t_user_workspaces.workspaceid = ?", params[:workspace_id])
    
      @c_users = MUser.select("m_users.id, m_users.name, m_users.email, t_user_channels.created_admin")
                      .joins("INNER JOIN t_user_channels ON t_user_channels.userid = m_users.id")
                      .where("t_user_channels.channelid = ?", params[:channel_id]).order(created_admin: :desc)
      
      @temp_c_users_id = MUser.select("id").joins("INNER JOIN t_user_channels ON t_user_channels.userid = m_users.id")
                              .where("t_user_channels.channelid = ?", params[:channel_id]).order(created_admin: :desc)
      @c_users_id = Array.new
      @temp_c_users_id.each { |r| @c_users_id.push(r.id) }

      @s_channel = MChannel.find_by(id: params[:channel_id])
      # render json:{
      #   users: @c_users_id ,
      #   sChannel: @s_channel
      # }
      #call from ApplicationController for retrieve home data
      # retrievehome
    end
  end


 
end