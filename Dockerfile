FROM debian:unstable-slim

RUN set -ex; \
  printf "deb http://deb.debian.org/debian unstable main\ndeb-src http://deb.debian.org/debian unstable main\n" > /etc/apt/sources.list; \
  apt update; \
  apt full-upgrade -y; \
  apt install -y --no-install-recommends \
    devscripts \
    build-essential \
    git \
    dh-make \
  ; \
  rm -rf /var/lib/apt/lists/* ;

RUN set -ex; \
  apt update; \
  mkdir /usr/local/src/vdr; \
  cd /usr/local/src/vdr; \
  apt source vdr; \
  apt build-dep -y --no-install-recommends \
    vdr \
  ; \
  git clone git://git.tvdr.de/vdr.git; \
  cd vdr; \
  COMMIT_ID="$(git show -s --format=%h)"; \
  VERSION="$(git tag | tail -n 1)"; \
  cd ..; \
  tar --exclude='vdr/.git*' -cvjf vdr_${VERSION}.orig.tar.bz2 vdr/; \
  cd vdr; \
  cp -pr ../vdr*/debian/ .; \
  printf "vdr-abi-${VERSION}-debian\n" > debian/abi-version; \
  sed -i '/skincurses-log-errors.patch/d; /allow-verbose-libsi-build.patch/d; /configurable-pkg-config.patch/d; /glibc-stime.patch/d;' debian/patches/series; \
  sed -i 's?skincurses.c .*Exp?skincurses.c 4.6 2020/05/11 10:23:15 kls Exp?' debian/patches/99_ncursesw-include.patch; \
  printf "12\n" > debian/plugin-template/compat; \
  sed -i 's/#BUILD_DEPS#, //g' debian/plugin-template/control; \
  > debian/plugin-template/install; \
  sed -i 's/dh_make -d/dh_make -y -d/' debian/debianize-vdrplugin; \
  export EMAIL=root@unknown; \
  dch "New upstream release" --newversion=${VERSION}-1~${COMMIT_ID}; \
  debuild; \
  VDR_VERSION=$(apt policy vdr | egrep Candidate | sed 's/.*: \(.*\)-.*$/\1/'); \
  dpkg -i /usr/local/src/vdr/vdr-dev*; \
  rm -rf /var/lib/apt/lists/* /usr/local/src/vdr/*${VDR_VERSION}* ;
