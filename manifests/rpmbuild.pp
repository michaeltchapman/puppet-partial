define partial::rpmbuild(
  $repo_source,
  $build_command,
  $repo_provider = 'git',
  $repo_revision = 'master',
  $build_environment = 'HOME=/tmp',
  $mirror_path = '/usr/share/yumrepo',
  $install_rpm = false,
)
{

  notice($title)
  notice($name)

  if $install_rpm {
    $install_string = 'yum install -y /tmp/*.rpm; '
  } else {
    $install_string = ''
  }

  vcsrepo { "/tmp/${title}":
    ensure   => present,
    provider => $repo_provider,
    revision => $repo_revision,
    source   => $repo_source,
  } ~>
  exec { "build_rpm_${title}":
    path          => '/usr/bin:/bin:/usr/sbin:/sbin',
    provider      => shell,
    command       => "cd /tmp; ${build_command}; cp /tmp/*.rpm ${mirror_path}; ${install_string}",
    refreshonly   => true,
    environment   => $build_environment
  }

  Exec["build_rpm_${title}"] ~> Exec<| title == 'create_yum_repo' |>
}
