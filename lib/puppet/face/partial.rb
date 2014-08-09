# Select and show a list of resources of a given type.
Puppet::Face.define(:partial, '0.0.1') do
  action :image_build do
    summary "Retrieve a catalog and filter it for image building resources like packages and repos"

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
      # REVISIT: Eventually, type should have a default value that triggers
      # the non-specific behaviour.  For now, though, this will do.
      # --daniel 2011-05-03
      catalog = Puppet::Resource::Catalog.indirection.find(host)

      img = catalog.resources.reject! { |res|
        (!(res.type.downcase == 'package' || res.type.downcase == 'yumrepo'))
      }

      hash = catalog.to_data_hash

      # This fails! WTF!?
      #tcat = Puppet::Resource::Catalog.from_data_hash(hash)

      tcat = Puppet::Resource::Catalog.new('test')
      anchor = tcat.create_resource('anchor', {'title' => 'break'})
      #thash = tcat.to_data_hash
      #puts thash.to_s

      puts '#TAGS'
      if !hash[:tags].nil? then
        hash[:tags].each do |key, value| 
          puts key.to_s
          puts value.to_s
        end
      else
        puts '{}'
      end

      puts '#NAME'
      puts hash[:name].to_s

      puts '#VERSION'
      puts hash[:version].to_s

      puts '#ENVIRONMENT'
      puts hash['environment'].to_s

      puts '#RESOURCES'
      #hash['resources'].each do |key, value|
      #  puts key
      #end

      #puts '#EDGES'
      #puts hash['edges'].to_s

      puts '#CLASSES'
      puts hash['classes'].to_s

      #puts hash.to_s

      img.each do |resource|
        resource[:notify] = []
        resource[:subscribe] = []
        if resource.type.downcase == 'package'
          resource[:before] = []
          #resource[:require] = [anchor]
        elsif resource.type.downcase == 'yumrepo'
          #resource[:before] = [anchor]
          resource[:require] = []
        end
      end
      img 
    end

    when_rendering :console do |value|
      return "derp"
      if value.nil? then
        "no matching resources found"
      else
        str = ''
        packages = []
        repos    = []
	value.each do |resource|
          if resource.type.downcase == 'package' then
            packages.push(resource)
          elsif resource.type.downcase == 'yumrepo' then
            repos.push(resource)
          end
        end

        str += "\#Repos: \n"
        repos.each do |repo|
          str += "yumrepo {'#{repo.title}':\n"
          if repo[:baseurl] then
            str += "  baseurl => '#{repo[:baseurl]}',\n"
          end
          str += "  before => Anchor['break']\n"
          str += "}\n"
          str += "\n"
        end

        str += "\#Anchor: \n"
        str += "anchor {'break':}\n"
        str += "\n"

        str += "\#Packages: \n"
        packages.each do |pkg|
          str += "package {'#{pkg.title}':\n"
          str += "  ensure => 'present',\n"
          str += "  require => Anchor['break']\n"
          str += "}\n"
          str += "\n"
        end
        str
      end
    end
  end
end
