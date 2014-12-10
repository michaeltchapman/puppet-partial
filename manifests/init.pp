class partial(
  $server_name = $::fqdn,
  $repo_path   = '/usr/share/yumrepo'
)
{
  include ::apache
  include ::apache::mod::autoindex
  include ::apache::mod::dir

  apache::vhost { "${server_name}":
    port           => '80',
    docroot        => $repo_path,
    directoryindex => 'index.html'
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
