#
# Cookbook Name:: collectd
# Recipe:: client_graphite
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "collectd::client"

if Chef::Config[:solo]
  if node['graphite'].nil?
    server = '127.0.0.1'
  else
    server = node['graphite']['server_address']
  end
else
  search(:node, "role:#{node['graphite']['server_role']} AND chef_environment:#{node.chef_environment}") do |n|
    server = n['ipaddress']
  end
end

cookbook_file 'carbon_writer_py' do
  source 'carbon_writer.py'
  path   "#{ node['collectd']['plugin_dir'] }/carbon_writer.py"
  owner  'root'
  group  'root'
  mode   0644
end

collectd_plugin 'carbon_writer' do
  options :line_receiver_host => server,
    :line_receiver_port => 2003,
    :derive_counters => true,
    :lowercase_metric_names => true,
    :differentiate_counters_over_time => true,
    'TypesDB' => node['collectd']['types_db']
  type 'python'
end
