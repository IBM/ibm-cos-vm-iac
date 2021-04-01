<!-- This should be the location of the title of the repository, normally the short name -->
# Infrastructure-as-code for IBM COS Trial VMs

<!-- Build Status, is a great thing to have at the top of your repository, it shows that you take your CI/CD as first class citizens -->
<!-- [![Build Status](https://travis-ci.org/jjasghar/ibm-cloud-cli.svg?branch=master)](https://travis-ci.org/jjasghar/ibm-cloud-cli) -->

<!-- Not always needed, but a scope helps the user understand in a short sentance like below, why this repo exists -->
## Scope

The purpose of this project is to demonstrate how a pure virtual variant of the [IBM Cloud Object Storage System](https://www.ibm.com/support/knowledgecenter/en/STXNRM)
can be built on top a KVM-based Linux virtualization host. Please note that this project as well as the operation
of IBM Cloud Object Storage System (IBM COS) deployed as KVM VMs is not supported by IBM and only to be used for
evaluation or demonstration purposes.

Please note that the VM templates for IBM COS are optimized to be as small as possible for a test system with regards to
(virtual) CPU assignment, RAM consuption and disk space. Depending on what you want to achieve with the test installation,
you might need to increase the values.

## Prerequisites

Before running the main build script from within the [source directory](src/) you need to have a Linux console on a system with
libvirt/KVM installed. Tests were performed on a Fedora 33 system.
You'll need at least the following packages installed
* qemu-img, qemu-kvm, libvirt, libvirt-client - for Fedora, please see [Getting started with Virtualization](https://docs.fedoraproject.org/en-US/quick-docs/getting-started-with-virtualization/)
* bash
* tar
* openssh
* expect

You need to download the IBM COS OVA files from [FixCentral](https://www.ibm.com/support/fixcentral/).
There might be authorization required, contact your IBM representative for help with that.
Place the ova files into the [OVA directory](ova/).
While testing this project, the following files were used:
```
clevos-3.15.5.55-accesser.ova
clevos-3.15.5.55-accesser.ova.md5
clevos-3.15.5.55-manager.ova
clevos-3.15.5.55-manager.ova.md5
clevos-3.15.5.55-slicestor.ova
clevos-3.15.5.55-slicestor.ova.md5
```

<!-- A more detailed Usage or detailed explaination of the repository here -->
## Usage

Review the [configuration file](./config.sh) to adjust the settings if required.
Please note that the `BASE_IP` parameter assumes to be the partial starting address of a
sequential address range for the devices. So if you enter a.b.c.d here the script will use
a.b.c.d0 for the manager, a.b.c.d1 for the accesser and a.b.c.d2, a.b.c.d3, a.b.c.d4 for
the 3 (default) slicestors. Please note that so far only 3 or 6 slicestors were tested.

To build the IBM COS system, open a terminal window, `cd` to the `src/` directory and run `./build.sh`

On a system with 6-core Intel i7, 64GB RAM and NVMe SSD the installation process will take
approximately 5 minutes for a 5-node system (manager, accesser, 3 slicestors).

Once the script is completed, point your browser on the host system to
https://<your manager IP>
and start configuring the system as described in the [documentation](https://www.ibm.com/support/knowledgecenter/en/STXNRM_3.15.5/coss.doc/managerAdmin_c3a5ccleversafe5cadminmanager5cchapter2_entire.html).

<!-- A notes section is useful for anything that isn't covered in the Usage or Scope. Like what we have below. -->
## Notes

This repository contains some example best practices for open source repositories:

* [LICENSE](LICENSE)
* [README.md](README.md)
* [CONTRIBUTING.md](CONTRIBUTING.md)
* [MAINTAINERS.md](MAINTAINERS.md)
<!-- A Changelog allows you to track major changes and things that happen, https://github.com/github-changelog-generator/github-changelog-generator can help automate the process -->
* [CHANGELOG.md](CHANGELOG.md)

> These are optional

<!-- The following are OPTIONAL, but strongly suggested to have in your repository. -->
* [dco.yml](.github/dco.yml) - This enables DCO bot for you, please take a look https://github.com/probot/dco for more details.
* [travis.yml](.travis.yml) - This is a example `.travis.yml`, please take a look https://docs.travis-ci.com/user/tutorial/ for more details.

These may be copied into a new or existing project to make it easier for developers not on a project team to collaborate.


<!-- Questions can be useful but optional, this gives you a place to say, "This is how to contact this project maintainers or create PRs -->
If you have any questions or issues you can create a new [issue here][issues].

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

All source files must include a Copyright and License header. The SPDX license header is 
preferred because it can be easily scanned.

If you would like to see the detailed LICENSE click [here](LICENSE).

```text
#
# Copyright 2020- IBM Inc. All rights reserved
# SPDX-License-Identifier: Apache2.0
#
```
## Authors

Optionally, you may include a list of authors, though this is redundant with the built-in
GitHub list of contributors.

- Author: New OpenSource IBMer <new-opensource-ibmer@ibm.com>

[issues]: https://github.com/IBM/repo-template/issues/new
