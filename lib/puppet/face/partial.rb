# Select and show a list of resources of a given type.
Puppet::Face.define(:partial, '0.0.1') do
  action :image_build do
    summary "Retrieve a catalog, filter it for image building resources like packages and repos, and apply it"

    option '--outfile OUTFILE' do
      summary 'Where to place a puppet manifest that can be applied'
    end

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
end
