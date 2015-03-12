# Select and show a list of resources of a given type.
Puppet::Face.define(:partial, '0.0.1') do
  action :repo_build do
    summary "Retrieve a catalog for a given role, filter it for resources like packages and repos, and create a local yum repository to serve"
    arguments "<role>"

    returns <<-'EOT'
      "Applies a catalog and doesn't return anything of note"
    EOT
    option "--repo_path REPO_PATH" do
      summary "The path to place package files in"
    end
    when_invoked do |role, options|
      facts = Puppet::Face[:facts, :current].find('node')
      facts.values['role'] = role

      node = Puppet::Node.new('role', options={:parameters => facts.values})

      catalog = Puppet::Resource::Catalog.indirection.find('role', options = {:use_node => node})

      if options.has_key? :repo_path
        path = options[:repo_path]
      else
        path = '/usr/share/yumrepo'
      end


      tcat = Puppet::Resource::Catalog.new('test', Puppet::Node::Environment.new('production'))
      tcat.make_default_resources
      anchor = tcat.create_resource('anchor', {'title' => 'start'})
      anchor = tcat.create_resource('anchor', {'title' => 'repos'})

      tcat.create_resource('file', {'title' => path, 'ensure' => 'directory', 'before' => 'Package[yum-utils]' })
      tcat.create_resource('package', {'title' => 'yum-utils', 'ensure' => 'installed', 'require' => 'Anchor[repos]' })

      catalog.resources.each do |res|
        if res.type.downcase == 'package' then
          tcat.create_resource('exec', { 'title' => "exec_#{res.title}", 'path' => '/usr/bin:/bin:/usr/sbin:/sbin', 'timeout' => 0, 'command' => "repotrack -a x86_64 -p #{path} #{res['name']}", 'require' => 'Package[yum-utils]'})
        elsif res.type.downcase == 'yumrepo'
          newres = res.to_hash
          newres[:before] = 'Anchor[repos]'
          newres.delete(:notify)
          newres.delete(:require)
          newres[:title] = res.title
          puts newres
          tcat.create_resource('yumrepo', newres)
        end
      end
      tcat.finalize
      transaction = tcat.apply()
      return
    end
  end

  action :image_build do
    summary "Retrieve a catalog, filter it for image building resources like packages and repos, and apply it"

    arguments "<host>"

    returns <<-'EOT'
      A puppet manifest containing the package and repository resources separated
      by an anchor.
    EOT

    description <<-'EOT'
    EOT

    notes <<-'NOTES'
      Work in progress as a packer provider
    NOTES

    examples <<-'EOT'
      Compile a catalog and select the resources for image building for the node compute1
      and output a simplified manifest to /root/image.pp

      $ puppet partial image_build somenode.magpie.lan --outfile=/root/image.pp
    EOT

    when_invoked do |host, options|
      catalog = Puppet::Resource::Catalog.indirection.find(host)

      tcat = Puppet::Resource::Catalog.new('test', Puppet::Node::Environment.new('production'))
      tcat.make_default_resources
      anchor = tcat.create_resource('anchor', {'title' => 'break'})

      catalog.resources.each do |res|
        if res.type.downcase == 'package' then
          tcat.create_resource('package', {'title' => res['name'], 'require' => 'Anchor[break]'})
        elsif res.type.downcase == 'yumrepo'
          tcat.create_resource('yumrepo', {'title' => res.title, 'name' => res['name'], 'baseurl' => res['baseurl'], 'before' => 'Anchor[break]' })
        end
      end
      tcat.finalize
      transaction = tcat.apply()
      return
    end
  end

  action :package_list do
    summary "Retrieve a catalog, filter packages list and create a list."

    arguments "<hosts>"

    returns <<-'EOT'
      A list containing the package resources.
    EOT

    description <<-'EOT'
    EOT

    notes <<-'NOTES'
    NOTES

    examples <<-'EOT'
      Compile a catalog and select the package resources managed by Puppet on one node.

      $ puppet partial package_list somenode.magpie.lan
    EOT

    when_invoked do |host, options|
      catalog = Puppet::Resource::Catalog.indirection.find(host)

      tcat = Puppet::Resource::Catalog.new('test', Puppet::Node::Environment.new('production'))
      tcat.make_default_resources

      catalog.resources.each do |res|
        if res.type.downcase == 'package' then
          puts "#{res['name']}"
        end
      end
      return
    end
  end

  action :service_list do
    summary "Retrieve a catalog, filter services list and create a list."

    arguments "<hosts>"

    option "--output_file <filename>" do
      summary "The path to place service list in"
    end

    returns <<-'EOT'
      A list containing the service resources.
    EOT

    description <<-'EOT'
    EOT

    notes <<-'NOTES'
    NOTES

    examples <<-'EOT'
      Compile a catalog and select the service resources managed by Puppet on one node/

      $ puppet partial service_list somenode.magpie.lan
    EOT

    when_invoked do |host, options|
      catalog = Puppet::Resource::Catalog.indirection.find(host)

      tcat = Puppet::Resource::Catalog.new('test', Puppet::Node::Environment.new('production'))
      tcat.make_default_resources

      catalog.resources.each do |res|
        if res.type.downcase == 'service' then
          puts "#{res['name']}"
        end
      end
      return
    end
  end

end
