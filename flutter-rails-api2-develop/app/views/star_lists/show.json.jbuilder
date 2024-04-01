json.t_direct_messages @t_direct_messages do |t_direct_message|
    json.id t_direct_message.id
    json.directmsg t_direct_message.directmsg
    json.created_at t_direct_message.created_at
    json.name t_direct_message.name
end

json.t_direct_threads @t_direct_threads do |t_direct_thread|
json.id t_direct_thread.id
json.directthreadmsg t_direct_thread.directthreadmsg
json.created_at t_direct_thread.created_at
json.name t_direct_thread.name
end

json.t_group_messages @t_group_messages do |t_group_message|
    json.id t_group_message.id
    json.groupmsg t_group_message.groupmsg
    json.created_at t_group_message.created_at
    json.name t_group_message.name
    json.channel_name t_group_message.channel_name
end

json.t_group_threads @t_group_threads do |t_group_thread|
    json.id t_group_thread.id
    json.groupthreadmsg t_group_thread.groupthreadmsg
    json.created_at t_group_thread.created_at
    json.name t_group_thread.name
    json.channel_name t_group_thread.channel_name
end
