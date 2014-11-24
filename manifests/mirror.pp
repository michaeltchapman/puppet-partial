class partial::mirror(
  build_server_name = 'build.domain.name,
  all_role          = 'all',
  repo_path         = '/usr/share/yumrepo'
)
{
  include ::apache

  apache::vhost { '$build_server_name':
    port    => '80',
    docroot => $repo_path
  }

  # this can take a very long time
  exec { 'build_repo':
    command => "puppet partial repo_build --repo_path=${repo_path} all",
    path    => ['/usr/bin', '/usr/local/bin','/usr/sbin','/sbin' ],
    timeout => 0
  }
}
