puppet-partial
==============

Puppet Face for building useful partial catalogs and applying them

Version 0.0.1

## Overview

The puppet-partial module is used to compile an existing puppet catalog and pull
out the parts that belong in golden images.

It can also create a local repo of all packages + package deps that are needed to
install a given catalog.

## Usage

the face is called partial, and the action for golden images is image_build:

    puppet partial image_build <nodename>

the action for building a repo is

    puppet partial repo_build <role_name>

the action of listing packages managed by a catalog:
    puppet partial resource_list --resource package <nodename>

the action of listing services managed by a catalog:
    puppet partial resource_list --resource service <nodename>

You can use resource_list to list any type of Puppet resource.

where role name will set a fact 'role' => <role_name> that can be used to select
which role to build for. To get the most out of this now, create a role that simply
includes every profile, so that all packages are downloaded.

TODO: add support for a list of roles, so that we don't have to make an all role.

## Limitations

All the image_build action currently does is pull out resources of the type 'package' and 'yumrepo'
and separate them with an anchor.

## License
Copyright (C) 2014 Aptira and Authors

Original Author: Michael Chapman

Aptira can be contacted at info@aptira.com


Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
