meshcommander-pfsense
=============

A script that installs the mesh commander software on pfSense and other FreeBSD systems


Usage
------------

To install the package and the rc script:

1. Log in to the pfSense command line shell as root.
2. Run this one-line command, which downloads the install script from Github and executes it with sh:

  ```
    fetch -o - https://raw.githubusercontent.com/matstatman/meshcommander-pfsense/master/install-meshcommander.sh | sh -s
  ```

The install script will install node14 and some dependencies, use npm and install mesh commander package, and start the the service on port 3000.

