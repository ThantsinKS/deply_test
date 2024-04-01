class DirectMessageController < ApplicationController
      def index
        @t_direct_message = TDirectMessage.all

        render json: @t_direct_message
      end
      def show
        #check unlogin user
      #  checkuser
      @m_user = MUser.find_by(id: @current_user)
        if params[:s_user_id].nil?
        render json: { error: 'Receive user not existed!', status: :unprocessable_enity }
        #  redirect_to home_url
        else
          @t_direct_message = TDirectMessage.new
          @t_direct_message.directmsg = params[:message]
          @t_direct_message.send_user_id = @m_user.id
          @t_direct_message.receive_user_id = params[:s_user_id]
          @t_direct_message.read_status = 0
          @t_direct_message.save

        #  session.delete(:r_direct_size)

          MUser.where(id: params[:s_user_id]).update_all(remember_digest: "1")
          
          @user = MUser.find_by(id: params[:s_user_id])
          render json: @t_direct_message
        #  redirect_to @user
        end
      end
  
      def showthread
        #check unlogin user
        # checkuser
        @m_user = MUser.find_by(id: @current_user)
        if params[:s_direct_message_id].nil?
          unless params[:s_user_id].nil?
            @user = MUser.find_by(id: params[:s_user_id])
            render json: @user
          end
        elsif params[:s_user_id].nil?
          render json: { error: 'Receive user not existed!'}
        else
          @t_direct_message = TDirectMessage.find_by(id: params[:s_direct_message_id])
          if @t_direct_message.nil?
            unless params[:s_user_id].nil?
              @user = MUser.find_by(id: params[:s_user_id])
              render json: @t_direct_message
            else
              # redirect_to home_url
            end
          else
            @t_direct_thread = TDirectThread.new
            @t_direct_thread.directthreadmsg = params[:message]
            @t_direct_thread.t_direct_message_id = params[:s_direct_message_id]
            @t_direct_thread.m_user_id =  @m_user.id
            @t_direct_thread.read_status = 0
            @t_direct_thread.save
            MUser.where(id: params[:s_user_id]).update_all(remember_digest: "1")
            render json: @t_direct_message
          end
        end
      end
      def deletemsg
        @s_user_id = MUser.find_by(id: @current_user)
        if  @s_user_id.nil?
          render json: { error: 'user not found!' }
        else
          direct_thread_ids = TDirectThread.where(t_direct_message_id: params[:id]).pluck(:id)
          TDirectThread.where(id: direct_thread_ids).destroy_all if direct_thread_ids.present?
      
          direct_message = TDirectMessage.find_by(id: params[:id])
          if direct_message
            direct_message.destroy
            @user = MUser.find_by(id: @s_user_id.id)
            render json: { success: 'Successfully Delete Messages' }
          else
            render json: { error: 'Message not found!' }, status: :not_found
          end
        end
      end
    
      def deletethread
        #check unlogin user
        # checkuser
    @s_user_id = MUser.find_by(id: @current_user)
        if params[:s_direct_message_id].nil?
          unless @s_user_id.nil?
            @user = MUser.find_by(id: @s_user_id)
            render json: { error:'Direct Message Not found'}
          end
        elsif @s_user_id.nil?
          render json: { error:'User not found'}
        else
          TDirectStarThread.where(directthreadid: params[:id]).destroy_all
          TDirectThread.find_by(id: params[:id]).destroy
    
          @t_direct_message = TDirectMessage.find_by(id: params[:s_direct_message_id])
          render json: { success:'Successfully Delete Messages'}
        end
      end
      
 end
