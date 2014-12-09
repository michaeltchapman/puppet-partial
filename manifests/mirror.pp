class partial::mirror(
  $all_role          = 'all',
  $repo_path         = '/usr/share/yumrepo',
  $upstream_cache    = false
)
{
  # pull from a local copy to speed things up if possible
  if $upstream_cache {
    exec { 'pull_from_upstream_cache':
      command => "cd ${repo_path}; wget -r -nH --cut-dirs=2 --no-parent --reject=\"index.html*\" http://${upstram_cache}/",
      path    => ['/usr/bin', '/usr/local/bin','/usr/sbin','/sbin' ],
      before  => Exec['build_repo'],
      timeout => 0
    }
  }

  # this can take a very long time
  Yumrepo<||> ->
  exec { 'build_repo':
    command => "puppet partial repo_build --repo_path=${repo_path} all",
    path    => ['/usr/bin', '/usr/local/bin','/usr/sbin','/sbin' ],
    timeout => 0
  }

  Exec['build_repo'] ~> Exec<| title == 'create_yum_repo' |>
}
