define partial::rpmbuild(
  $repo_source,
  $build_command,
  $repo_provider = 'git',
  $repo_revision = 'master',
  $build_environment = 'HOME=/tmp',
  $mirror_path = '/usr/share/yumrepo',
)
{

  notice($title)
  notice($name)

  vcsrepo { "/tmp/${title}":
    ensure   => present,
    provider => $repo_provider,
    revision => $repo_revision,
    source   => $repo_source,
  } ~>
  exec { "build_rpm_${title}":
    path          => '/usr/bin:/bin:/usr/sbin:/sbin',
    provider      => shell,
    command       => "cd /tmp; ${build_command}; cp /tmp/*.rpm ${mirror_path}",
    refreshonly   => true,
    environment   => $build_environment
  }

  Exec["build_rpm_${title}"] ~> Exec<| title == 'create_yum_repo' |>
}
