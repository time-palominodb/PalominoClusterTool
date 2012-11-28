# TODO This needs to actually use the gpg keys... derp.

case node[:platform]
when "redhat", "centos", "scientific", "fedora"

  platform_major_version = node[:platform_version].to_i

  if node[:hadoop][:yum_repo_url]
    yum_repo_url = node[:hadoop][:yum_repo_url]
  else
    case platform_major_version
    when 5
      yum_repo_url = "http://archive.cloudera.com/redhat/cdh/#{node[:hadoop][:release]}"
    when 6
      yum_repo_url = "http://archive.cloudera.com/redhat/6/x86_64/cdh/#{node[:hadoop][:release]}"
    end
  end

  yum_repository "cloudera-cdh#{node[:hadoop][:release]}" do
    name "cloudera-cdh#{node[:hadoop][:release]}"
    description "Cloudera's Hadoop Version CDH#{node[:hadoop][:release]}"
    url yum_repo_url
    action :add
  end
end
