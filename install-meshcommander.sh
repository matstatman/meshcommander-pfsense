#!/bin/sh

# install-meshcommander.sh
# Installs the mesh commander software on a FreeBSD machine (presumably running pfSense).

# The rc script associated with this branch or fork:
RC_SCRIPT_URL="https://raw.githubusercontent.com/matstatman/meshcommander-pfsense/master/rc.d/meshcommander.sh"

# If pkg-ng is not yet installed, bootstrap it:
if ! /usr/sbin/pkg -N 2> /dev/null; then
  echo "FreeBSD pkgng not installed. Installing..."
  env ASSUME_ALWAYS_YES=YES /usr/sbin/pkg bootstrap
  echo " done."
fi

# If installation failed, exit:
if ! /usr/sbin/pkg -N 2> /dev/null; then
  echo "ERROR: pkgng installation failed. Exiting."
  exit 1
fi

# Determine this installation's Application Binary Interface
ABI=`/usr/sbin/pkg config abi`

# FreeBSD package source:
FREEBSD_PACKAGE_URL="https://pkg.freebsd.org/${ABI}/latest/All/"

# FreeBSD package list:
FREEBSD_PACKAGE_LIST_URL="https://pkg.freebsd.org/${ABI}/latest/packagesite.txz"

# Stop the controller if it's already running...
# First let's try the rc script if it exists:
if [ -f /usr/local/etc/rc.d/meshcommander.sh ]; then
  echo -n "Stopping the meshcommander service..."
  /usr/sbin/service meshcommander.sh stop
  rm -rf /usr/local/meshcommander
  echo " done."
fi


echo "Installing required packages..."

fetch ${FREEBSD_PACKAGE_LIST_URL}
tar vfx packagesite.txz

AddPkg () {
 	pkgname=$1
        pkg unlock -yq $pkgname
 	pkginfo=`grep "\"name\":\"$pkgname\"" packagesite.yaml`
 	pkgvers=`echo $pkginfo | pcregrep -o1 '"version":"(.*?)"' | head -1`

	# compare version for update/install
 	if [ `pkg info | grep -c $pkgname-$pkgvers` -eq 1 ]; then
	     echo "Package $pkgname-$pkgvers already installed."
	else
	     env ASSUME_ALWAYS_YES=YES /usr/sbin/pkg add -f ${FREEBSD_PACKAGE_URL}${pkgname}-${pkgvers}.pkg
       pkg lock -yq $pkgname
}

#Add the following Packages for installation or reinstallation (if something was removed)
AddPkg gmake
AddPkg brotli
AddPkg c-ares
AddPkg icu
AddPkg node14
AddPkg npm-node14

# Clean up downloaded package manifest:
rm packagesite.*

echo " done."


echo -n "Installing mesh commander in /usr/local/meshcommander"
mkdir -p /usr/local/meshcommander
cd /usr/local/meshcommander/
npm install meshcommander
echo " done."

# Fetch the rc script from github:
echo -n "Installing rc script..."
/usr/bin/fetch -o /usr/local/etc/rc.d/meshcommander.sh ${RC_SCRIPT_URL}
echo " done."

# Fix permissions so it'll run
chmod +x /usr/local/etc/rc.d/meshcommander.sh

# Add the startup variable to rc.conf.local.
# Eventually, this step will need to be folded into pfSense, which manages the main rc.conf.
# In the following comparison, we expect the 'or' operator to short-circuit, to make sure the file exists and avoid grep throwing an error.
if [ ! -f /etc/rc.conf.local ] || [ $(grep -c meshcommander_enable /etc/rc.conf.local) -eq 0 ]; then
  echo -n "Enabling the meshcommander service..."
  echo "meshcommander_enable=YES" >> /etc/rc.conf.local
  echo " done."
fi

# Start it up:
echo -n "Starting the meshcommander service..."
echo /usr/sbin/service meshcommander.sh start
echo " done."
