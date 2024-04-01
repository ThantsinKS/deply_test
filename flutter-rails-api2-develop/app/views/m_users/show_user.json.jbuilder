json.user do
  json.id @m_user.id
  json.name @m_user.name
  json.email @m_user.email
  json.admin @m_user.admin
end
json.workspace do
  json.id @m_workspace.id
  json.name @m_workspace.workspace_name
end
if @M_users
  json.M_users @M_users
end
if @M_channels
  json.M_channels @M_channels
end
if @M_P_channels
  json.M_P_channels @M_P_channels
end
if @M_channelsids
  json.M_channelsids @M_channelsids
end