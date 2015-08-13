class partial::mirror(
  $all_role          = 'all',
  $repo_path         = '/usr/share/yumrepo',
  $upstream_cache    = false,
  $mirror_installed  = true
)
{
  package { 'wget':
    ensure => 'installed'
  }

  # pull from a local copy to speed things up if possible
  if $upstream_cache {
    exec { 'pull_from_upstream_cache':
      command => "cd ${repo_path}; wget -r -nH --cut-dirs=2 --no-parent --reject=\"index.html*\" http://${upstream_cache} || true",
      path    => ['/usr/bin', '/usr/local/bin','/usr/sbin','/sbin' ],
      before  => Exec['build_repo'],
      timeout => 0,
      creates => '/usr/share/yumrepo/repodata',
      require => Package['wget']
    }
  }

  # this can take a very long time

  Exec<| title == 'vagrant_rpm_cache' |> -> Exec <| title == 'build_repo' |>
  Exec<| title == 'vagrant_rpm_cache' |> -> Exec <| title == 'build_installed_repo' |>

  Yumrepo<||> ->
  exec { 'build_repo':
    command => "puppet partial repo_build --repo_path=${repo_path} all",
    path    => ['/usr/bin', '/usr/local/bin','/usr/sbin','/sbin' ],
    timeout => 0
  }

  if $mirror_installed {
    exec { 'build_installed_repo':
      command => "ret=1; for i in `puppet resource package | grep package | cut -d \"'\" -f 2`; do repotrack -a x86_64 -p ${repo_path} \$i; done;",
      path    => ['/usr/bin', '/usr/local/bin','/usr/sbin','/sbin' ],
      timeout => 0,
      provider => shell
    }
    Exec['build_installed_repo'] ~> Exec<| title == 'create_yum_repo' |>
  }

  Exec['build_repo'] ~> Exec<| title == 'create_yum_repo' |>
}
