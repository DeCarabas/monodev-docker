#!/bin/bash
# This is the script that we use to set up the docker image for Mono 4.8.0.
#
# This is a script instead of a bunch of RUN commands so that we can change
# the working directory to build mono, which we need for autogen.sh.
#
# I know, set -e is not recommended, but it works for this particular script and makes it so much more readable.
# Proper tools for the proper job.
set -e

apt-get update -q

# Fetch, build, and install Mono 4.8 (from source, since the packages that exist are no good.)
apt-get install -y -q git autoconf libtool automake build-essential mono-devel gettext cmake python

mkdir /tmp/mono
cd /tmp/mono

export MONO_TLS_PROVIDER=btls

MONO_PREFIX=/opt/mono
MONO_VERSION=4.8.0

curl https://download.mono-project.com/sources/mono/mono-4.8.0.374.tar.bz2 -o mono-$MONO_VERSION.tar.bz2
tar xf mono-$MONO_VERSION.tar.bz2
cd mono-$MONO_VERSION
./autogen.sh --prefix=$MONO_PREFIX
make
make install

curl -L -o /tmp/mono/certdata.txt https://hg.mozilla.org/releases/mozilla-release/raw-file/default/security/nss/lib/ckfw/builtins/certdata.txt
/opt/mono/bin/mozroots --import --sync --file /tmp/mono/certdata.txt
/opt/mono/bin/btls-cert-sync

curl -o /opt/mono/nuget.exe https://dist.nuget.org/win-x86-commandline/latest/nuget.exe

apt-get install libgdiplus --no-install-recommends -y

# CLEANUP
apt-get remove -y -q git autoconf libtool automake build-essential mono-devel gettext cmake python
apt-get autoremove -y -q
rm -rf /var/lib/apt/lists/*
