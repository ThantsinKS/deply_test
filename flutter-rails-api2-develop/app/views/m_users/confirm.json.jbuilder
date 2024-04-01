json.user do
  json.email @m_user.email
end
json.workspace do
  json.workspace_name @m_workspace.workspace_name
end
json.channel do
  json.channel_name @m_channel.channel_name
end