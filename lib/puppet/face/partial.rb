# Select and show a list of resources of a given type.
Puppet::Face.define(:partial, '0.0.1') do
  action :select do
    summary "Retrieve a catalog and filter it for stuff"
    arguments "<host>"
    returns <<-'EOT'
      A list of resource references ("Type[title]"). When used from the API,
      returns an array of Puppet::Resource objects excised from a catalog.
    EOT
    description <<-'EOT'
      Retrieves a catalog for the specified host, then searches it for all
      resources of the requested type.
    EOT
    notes <<-'NOTES'
      By default, this action will retrieve a catalog from Puppet's compiler
      subsystem; you must call the action with `--terminus rest` if you wish
      to retrieve a catalog from the puppet master.

      FORMATTING ISSUES: This action cannot currently render useful yaml;
      instead, it returns an entire catalog. Use json instead.
    NOTES
    examples <<-'EOT'
      Ask the puppet master for a list of managed file resources for a node:

      $ puppet catalog select --terminus rest somenode.magpie.lan file
    EOT
    when_invoked do |host, options|
      # REVISIT: Eventually, type should have a default value that triggers
      # the non-specific behaviour.  For now, though, this will do.
      # --daniel 2011-05-03
      catalog = Puppet::Resource::Catalog.indirection.find(host)

      catalog.resources.reject { |res| (res.type.downcase != 'package' && res.type.downcase != 'yumrepo') }
      #catalog.resources
    end

    when_rendering :console do |value|
      if value.nil? then
        "no matching resources found"
      else
        str = ''
        packages = []
        repos    = []
	value.each do |resource|
          if resource.type.downcase == 'package' then
            packages.push(resource)
          elsif resource.type.downcase == 'yumrepo' 
            repos.push(resource)
          end
        end
        str += "Repos: \n"
        repos.each do |repo|
          str += "#{repo.title}\n"
          if repo[:baseurl] then
            str += "#{repo[:baseurl]}\n"
          end
        end
        str += "Packages: \n"
        packages.each do |pkg|
          str += "#{pkg[:name]}\n"
        end
        str
      end
    end
  end
end
