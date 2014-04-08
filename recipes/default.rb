base_uri = "http://dl.fedoraproject.org/pub/epel"
rpms     = {
  5 => "epel-release-5-4.noarch.rpm",
  6 => "epel-release-6-8.noarch.rpm",
}

rhel_version = node[:platform_version].to_i
raise "#{rhel_version} is not support version." if rpms[rhel_version].nil?

arch = node[:kernel][:machine]
if arch == "i686"
  arch = "i386"
end

rpm_uri = "#{base_uri}/#{rhel_version}/#{arch}/#{rpms[rhel_version]}"
tmp_rpm = "#{Chef::Config[:file_cache_path]}/#{rpms[rhel_version]}"

remote_file tmp_rpm do
  owner  "root"
  group  "root"
  source rpm_uri
end

rpm_package rpms[rhel_version] do
  source  tmp_rpm
  action  :install
end

file tmp_rpm do
  action  :delete

  only_if { File.exist?(tmp_rpm) }
end

package "epel-release" do
  action node[:epel][:action]

  not_if node[:epel][:action].nil?
end
