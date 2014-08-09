puppet-partial
==============

Puppet Face for building partial catalogs and applying them

Version 0.0.1

## Overview

The puppet-partial module is used to compile an existing puppet catalog and pull
out the parts that belong in golden images.

## Usage

the face is called partial, and the only action at the moment is image_build:

    puppet partial image_build <nodename>
    
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
