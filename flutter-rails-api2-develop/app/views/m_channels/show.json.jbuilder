json.m_channel do 
    json.id @m_channel.id
    json.channel_name @m_channel.channel_name
    json.channel_status @m_channel.channel_status
    json.m_workspace @m_channel.m_workspace
end
  json.t_group_messages  @t_group_messages
  json.s_channel @s_channel
  json.m_channel_users @m_channel_users
  json.t_group_star_msgids @t_group_star_msgids
  json.u_count @u_count
  json.t_group_message_dates @t_group_message_dates
  json.t_group_message_datesize @t_group_message_datesize
  json.id @m_channel.id
  json.channel_name @m_channel.channel_name
  json.channel_status @m_channel.channel_status
  json.m_workspace @m_channel.m_workspace
if @retrieve_group_message
  json.retrieve_group_message @retrieve_group_message
end
