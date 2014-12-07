class partial::rpm(
  $rpms = {}
)
{
  package { ['git', 'gcc', 'rpmdevtools', 'mock']:
    ensure => installed
  }
  notice($rpms)
  create_resources('partial::rpmbuild', $rpms )
}
