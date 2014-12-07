class partial::mirror(
  $all_role          = 'all',
  $repo_path         = '/usr/share/yumrepo'
)
{
  # this can take a very long time
  Yumrepo<||> ->
  exec { 'build_repo':
    command => "puppet partial repo_build --repo_path=${repo_path} all",
    path    => ['/usr/bin', '/usr/local/bin','/usr/sbin','/sbin' ],
    timeout => 0
  }

  Exec['build_repo'] ~> Exec<| title == 'create_yum_repo' |>
}
