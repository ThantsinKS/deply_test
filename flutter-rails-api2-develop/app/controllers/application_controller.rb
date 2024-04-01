class ApplicationController < ActionController::API
  include JsonWebToken
  before_action :authenticate_request
  def retrievehome
    @m_workspace = MWorkspace.find_by(id: @current_workspace)
    @m_user = MUser.find_by(id: @current_user)
    @m_users = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id
                          INNER JOIN m_workspaces ON m_workspaces.id = t_user_workspaces.workspaceid")
      .where("m_users.member_status = 1 and m_workspaces.id = ?", @current_workspace)
    @m_channels = MChannel.select("m_channels.id, channel_name, channel_status, t_user_channels.message_count, t_user_channels.created_admin").joins(
      "INNER JOIN t_user_channels ON t_user_channels.channelid = m_channels.id"
    ).where("(m_channels.m_workspace_id = ? and t_user_channels.userid = ?)", @current_workspace, @current_user).order(id: :asc)
    @m_p_channels = MChannel.select("m_channels.id, channel_name, channel_status")
      .where("(m_channels.channel_status = 1 and m_channels.m_workspace_id = ?)", @current_workspace).order(id: :asc)
    @direct_msgcounts = []
    @m_users.each do |muser|
      direct_count = TDirectMessage.where(send_user_id: muser.id, receive_user_id: @current_user, read_status: 0)
      thread_count = TDirectThread.joins("INNER JOIN t_direct_messages ON t_direct_messages.id = t_direct_threads.t_direct_message_id")
                                    .where("t_direct_threads.read_status = 0 and t_direct_threads.m_user_id = ? and
                                    ((t_direct_messages.send_user_id = ? and t_direct_messages.receive_user_id = ?) ||
                                    (t_direct_messages.send_user_id = ? and t_direct_messages.receive_user_id = ?))",
                                    muser.id, muser.id, @current_user, @current_user, muser.id)
      @direct_msgcounts.push(direct_count.size + thread_count.size)
    end
    @all_unread_count = 0
    @m_channels.each do |c|
      @all_unread_count += c.message_count
    end
    @direct_msgcounts.each do |c|
      @all_unread_count +=c
    end
    @m_channelsids = Array.new
    @m_channels.each do|m_channel|
      @m_channelsids.push(m_channel.id)
    end
    # {
    #   m_users: @m_users,
    #   m_channels: @m_channels,
    #   direct_msgcounts: @direct_msgcounts,
    #   all_unread_count: @all_unread_count,
    #   m_channelsids: @m_channelsids
    # }
    @M_users = {m_users: @m_users}
    @M_channels = {m_channels: @m_channels}
    @M_P_channels = {m_p_channels: @m_p_channels}
    @M_channelsids = {m_channelsids: @m_channelsids}
    @retrievehome = { m_users: @m_users, m_channels: @m_channels, direct_msgcounts: @direct_msgcounts, all_unread_count: @all_unread_count,m_channelsids: @m_channelsids }
  end

  def retrieve_direct_message(second_user)
    @m_user = MUser.find_by(id: second_user)
    # render json: @m_user, status: :ok
    TDirectMessage.where(send_user_id: @current_user, receive_user_id: @m_user, read_status: 0).update_all(read_status: 1)
    TDirectThread.joins("INNER JOIN t_direct_messages ON t_direct_messages.id = t_direct_threads.t_direct_message_id").where(
    "(t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? ) || (t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? )", 
    @m_user,  @current_user, @m_user, @current_user
    ).where.not(m_user_id: @m_user, read_status: 1).update_all(read_status: 1)

    @s_user_id = MUser.find_by(id: @current_user)
    # render json: @current_user, status: :ok

    @t_direct_messages = TDirectMessage.select("name, directmsg, t_direct_messages.id as id, t_direct_messages.created_at  as created_at, t_direct_messages.send_user_id as send_user_id,t_direct_messages.receive_user_id as receive_user_id,
                                          (select count(*) from t_direct_threads where t_direct_threads.t_direct_message_id = t_direct_messages.id) as count")
                                        .joins("INNER JOIN m_users ON m_users.id = t_direct_messages.send_user_id")
                                        .where("(t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? ) 
                                          || (t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? )", 
                                          @m_user,  @current_user, @current_user,  @m_user).order(created_at: :desc).limit(@r_direct_size)
  
    @t_direct_messages = @t_direct_messages.reverse

    @temp_direct_star_msgids = TDirectStarMsg.select("directmsgid").where("userid = ?", @s_user_id)

    @t_direct_star_msgids = Array.new
    @temp_direct_star_msgids.each { |r| @t_direct_star_msgids.push(r.directmsgid) }

    @t_direct_message_dates = TDirectMessage.select("distinct DATE(created_at) as created_date")
    .where("(t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? ) 
    || (t_direct_messages.receive_user_id = ? and t_direct_messages.send_user_id = ? )", 
    @m_user,  @current_user,  @current_user, @m_user)
    
    @t_direct_message_datesize = Array.new
    @t_direct_messages.each{|d| @t_direct_message_datesize.push(d.created_at.strftime("%F").to_s)}
  
    # Construct response hash
    @retrieve_direct_message = { s_user: @s_user_id, t_direct_messages: @t_direct_messages, t_direct_star_msgids: @temp_direct_star_msgids,
                                 t_direct_message_dates: @t_direct_message_dates, t_direct_message_datesize: @t_direct_message_datesize }
 
  end

  def retrieve_direct_thread(directMessageID)
    @m_user = MUser.find_by(id: @userid)
    @s_user = MUser.find_by(id: 2)
    @t_direct_message = TDirectMessage.find_by(id: directMessageID)
    @send_user = MUser.find_by(id: @t_direct_message.send_user_id)
    TDirectThread.where.not(m_user_id: @m_user, read_status: 1).update_all(read_status: 1)
    @t_direct_threads = TDirectThread.select("name, directthreadmsg, t_direct_threads.id as id, t_direct_threads.created_at  as created_at")
                .joins("INNER JOIN t_direct_messages ON t_direct_messages.id = t_direct_threads.t_direct_message_id
                        INNER JOIN m_users ON m_users.id = t_direct_threads.m_user_id")
                .where("t_direct_threads.t_direct_message_id = ?", directMessageID).order(id: :asc)
    @temp_direct_star_thread_msgids = TDirectStarThread.select("directthreadid").where("userid = ?", @m_user)
    @t_direct_star_thread_msgids = Array.new
    @temp_direct_star_thread_msgids.each { |r| @t_direct_star_thread_msgids.push(r.directthreadid) }
    {
      "t_direct_threads": @t_direct_threads,
      "t_direct_message": @t_direct_message
    }
  end
  # def retrieve_direct_thread
  #   #  @s_user = MUser.find_by(id: @s_user_id)
         
  #   #  @t_direct_message = TDirectMessage.find_by(id: @s_direct_message_id)
  #   #  @send_user = MUser.find_by(id: @t_direct_message.send_user_id)

  #   @userid = params[:m_user_id]
 
  #    TDirectThread.where.not(m_user_id:  @userid , read_status: 1).update_all(read_status: 1)
 
  #    @t_direct_threads = TDirectThread.select("m_users.id as sendUser, t_direct_threads.directthreadmsg as message, t_direct_messages.directmsg as replymsg, t_direct_threads.id as id, t_direct_threads.created_at  as created_at")
  #                .joins("INNER JOIN t_direct_messages ON t_direct_messages.id = t_direct_threads.t_direct_message_id
  #                        INNER JOIN m_users ON m_users.id = t_direct_threads.m_user_id")
  #                .where("t_direct_threads.m_user_id = ?", @userid).order(id: :asc)
     
  #    @temp_direct_star_thread_msgids = TDirectStarThread.select("directthreadid").where("userid = ?", @userid)
 
  #    @t_direct_star_thread_msgids = Array.new
  #    @temp_direct_star_thread_msgids.each { |r| @t_direct_star_thread_msgids.push(r.directthreadid) }
  #    @retrieve_direct_thread = {t_direct_threads: @t_direct_threads, t_direct_star_thread_msgids: @t_direct_star_thread_msgids }
  #  end
  def retrieve_group_message
    @m_workspace = MWorkspace.find_by(id: @current_workspace)
    @m_user = MUser.find_by(id: @current_user)
    @s_channel = MChannel.find_by(id: params[:id])
    @m_channel_users = MUser.joins("INNER JOIN t_user_channels on t_user_channels.userid = m_users.id 
                                    INNER JOIN m_channels ON m_channels.id = t_user_channels.channelid")
                                .where("m_users.member_status = 1 and m_channels.m_workspace_id = ? and m_channels.id = ?",
                                @m_workspace, @s_channel)

    TUserChannel.where(channelid: @s_channel, userid:  @m_user).update_all(message_count: 0, unread_channel_message: nil)

    @t_group_messages = TGroupMessage.select("name, groupmsg, t_group_messages.id as id, t_group_messages.created_at as created_at,t_group_messages.m_user_id as m_user_id,  
                                            (select count(*) from t_group_threads where t_group_threads.t_group_message_id = t_group_messages.id) as count ")
                                      .joins("INNER JOIN m_users ON m_users.id = t_group_messages.m_user_id")
                                      # .where("m_channel_id = ? ", @s_channel).order(created_at: :desc).limit(10)
                                      .where("m_channel_id = ? ", @s_channel).order(created_at: :desc)
    @t_group_messages = @t_group_messages.reverse
    @temp_group_star_msgids = TGroupStarMsg.select("groupmsgid").where("userid = ?",  @m_user)

    @t_group_star_msgids = Array.new
    @temp_group_star_msgids.each { |r| @t_group_star_msgids.push(r.groupmsgid) }
    @u_count = TUserChannel.where(channelid: @s_channel).count
    @t_group_message_dates = TGroupMessage.select("distinct DATE(created_at) as created_date").where("m_channel_id = ? ", @s_channel)
    # render json: @t_group_message_dates, status: :ok
    @t_group_message_datesize = Array.new
    @t_group_messages.each{|d| @t_group_message_datesize.push(d.created_at.strftime("%F").to_s)}
    # render json: @t_group_message_datesize, status: :ok
    @retrieve_group_message={
      "current_user": @m_user,
      "s_channel": @s_channel,
      "t_group_messages": @t_group_messages,
      "m_channel_users": @m_channel_users,
      "t_group_star_msgids": @t_group_star_msgids,
      "u_count": @u_count,
      "t_group_message_dates": @t_group_message_dates,
      "t_group_message_datesize": @t_group_message_datesize
    }
  end
  def retrieve_group_thread
    @m_workspace = MWorkspace.find_by(id: @current_workspace)
    @m_user = MUser.find_by(id: @current_user)
    @s_channel = MChannel.find_by(id: params[:s_channel_id])

    @m_channel_users = MUser.joins("INNER JOIN t_user_channels on t_user_channels.userid = m_users.id 
                                    INNER JOIN m_channels ON m_channels.id = t_user_channels.channelid")
                                .where("m_users.member_status = 1 and m_channels.m_workspace_id = ? and m_channels.id = ?",
                                @current_workspace, params[:s_channel_id])
                                
    TUserChannel.where(channelid: params[:s_channel_id], userid:  @current_user).update_all(message_count: 0, unread_channel_message: nil)
    
    @t_group_message = TGroupMessage.find_by(id: params[:s_group_message_id])
    @send_user = MUser.find_by(id: @t_group_message.m_user_id)

    @t_group_threads = TGroupThread.select("name, groupthreadmsg, t_group_threads.id as id, t_group_threads.created_at  as created_at")
                    .joins("INNER JOIN t_group_messages ON t_group_messages.id = t_group_threads.t_group_message_id
                          INNER JOIN m_users ON m_users.id = t_group_threads.m_user_id").where("t_group_threads.t_group_message_id = ?", params[:s_group_message_id]).order(id: :asc)
    
    @temp_group_star_thread_msgids = TGroupStarThread.select("groupthreadid").where("userid = ?", @current_user)

    @t_group_star_thread_msgids = Array.new
    @temp_group_star_thread_msgids.each { |r| @t_group_star_thread_msgids.push(r.groupthreadid) }
    
    @u_count = TUserChannel.where(channelid: params[:s_channel_id]).count
  
    @retrieve_group_thread = 
    {m_channel_users: @m_channel_users, 
    t_group_message: @t_group_message, 
    send_user: @send_user, 
    t_group_threads: @t_group_threads, 
    t_group_star_thread_msgids: @t_group_star_thread_msgids, 
    u_count: @u_count}
  end

  private

 
  def authenticate_request
    header = request.headers["Authorization"]
  
    if header.present?
      header = header.split.last
      begin
        decoded = jwt_decode(header)
        @current_user = MUser.find(decoded[:user_id])
        @current_workspace = MWorkspace.find(decoded[:workspace_id])
      rescue JWT::DecodeError => e
        render json: { error: "Invalid token" }, status: :unauthorized
        return
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: "User or workspace not found" }, status: :not_found
        return
      end
    else
      render json: { error: "Authorization header missing" }, status: :unauthorized
      return
    end
  end
  
end
