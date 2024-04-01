class StarListsController < ApplicationController

    def show
        #check unlogin user
        # checkuser
  
        # session.delete(:s_user_id)
        # session.delete(:s_channel_id)
        # session.delete(:s_direct_message_id)
        # session.delete(:s_group_message_id)
        # session.delete(:r_direct_size)
        # session.delete(:r_group_size)
        @m_user = MUser.find_by(id: @current_user)
        @t_direct_messages=TDirectMessage.select("t_direct_messages.id,t_direct_messages.directmsg,t_direct_messages.created_at,m_users.name")
                                        .joins("INNER JOIN t_direct_star_msgs ON t_direct_messages.id=t_direct_star_msgs.directmsgid
                                                INNER JOIN m_users ON m_users.id=t_direct_messages.send_user_id")
                                        .where("t_direct_star_msgs.userid=?",@m_user.id).order(id: :asc)
    
        @t_direct_threads=TDirectThread.select("t_direct_threads.id,t_direct_threads.directthreadmsg,t_direct_threads.created_at,m_users.name")
                                                .joins("INNER JOIN t_direct_star_threads ON t_direct_threads.id=t_direct_star_threads.directthreadid
                                                INNER JOIN m_users ON m_users.id=t_direct_threads.m_user_id")
                                                .where("t_direct_star_threads.userid=?",@m_user.id).order(id: :asc)
  
        @t_group_messages=TGroupMessage.select("t_group_messages.id,t_group_messages.groupmsg,t_group_messages.created_at,m_users.name,m_channels.channel_name")
                                                .joins("INNER JOIN t_group_star_msgs ON t_group_messages.id=t_group_star_msgs.groupmsgid
                                                INNER JOIN m_users ON  t_group_messages.m_user_id=m_users.id
                                                INNER JOIN m_channels ON t_group_messages.m_channel_id = m_channels.id")
                                                .where("t_group_star_msgs.userid=?",@m_user.id).order(id: :asc)
  
        @t_group_threads=TGroupThread.select("t_group_threads.id,t_group_threads.groupthreadmsg,t_group_threads.created_at,m_users.name,m_channels.channel_name") 
                                            .joins("INNER JOIN t_group_star_threads ON t_group_threads.id=t_group_star_threads.groupthreadid
                                              INNER JOIN t_group_messages ON t_group_messages.id=t_group_threads.t_group_message_id
                                              INNER JOIN m_users ON m_users.id=t_group_threads.m_user_id
                                              INNER JOIN m_channels ON t_group_messages.m_channel_id = m_channels.id")            
                                              .where("t_group_star_threads.userid=?",@m_user.id).order(id: :asc)         
        
        #call from ApplicationController for retrieve home data
        retrievehome

      #   render json:{
      #   t_direct_messages: @t_direct_messages,
      #   t_direct_threads: @t_direct_threads,
      #   t_group_messages: @t_group_messages,
      #   t_group_threads: @t_group_threads

      # }
      end
end
