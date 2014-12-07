class partial(
  $build_server_name = 'build.domain.name',
  $repo_path         = '/usr/share/yumrepo'
)
{
  include ::apache

  apache::vhost { "${build_server_name}":
    port    => '80',
    docroot => $repo_path
  }

  firewall { '100 accept all tcp 80 for apache':
    proto => 'tcp',
    action => 'accept',
    port => [80, 443]
  }

  package { 'createrepo':
    ensure => 'installed',
  }
  
  file  { $repo_path:
    ensure => directory 
  } ->

  exec { 'create_yum_repo':
    command => "createrepo ${repo_path}",
    path    => ['/usr/bin', '/usr/local/bin','/usr/sbin','/sbin' ],
    timeout => 0,
    require => Package['createrepo']
  }
}
