Environment used to compile VDR plugins

Create the image:
```
git clone https://github.
cd docker-vdr-build
docker build . -t vdr-build
```

Run the images and compile femon (For example):
```
docker run --rm -it -v /tmp/plugins:/usr/local/src/plugins vdr-build /bin/bash
export USER=root
export EMAIL="${USER}@unknown"
export VERSION_PACKAGE=1
PLUGIN=femon
mkdir /usr/local/src/plugins/${PLUGIN}
cd /usr/local/src/plugins/${PLUGIN}
git clone https://github.com/rofafor/vdr-plugin-femon.git vdr-plugin-${PLUGIN}
cd vdr-plugin-${PLUGIN}
COMMIT_ID="$(git show -s --format=%h)"
VERSION="$(git tag | tail -n 1 | sed 's/^v//g')"
cd ..
mv vdr-plugin-${PLUGIN} vdr-plugin-${PLUGIN}-${VERSION}~${COMMIT_ID}
tar --exclude='*/.git*' -czf vdr-plugin-${PLUGIN}-${VERSION}~${COMMIT_ID}.tar.gz vdr-plugin-${PLUGIN}-${VERSION}~${COMMIT_ID}
cd vdr-plugin-${PLUGIN}-${VERSION}~${COMMIT_ID}
debianize-vdrplugin
mv ../vdr-plugin-${PLUGIN}_${VERSION}~${COMMIT_ID}.orig.tar.gz ../vdr-plugin-${PLUGIN}_${VERSION}.orig.tar.gz
dch -v ${VERSION}-${VERSION_PACKAGE}~${COMMIT_ID} "version: ${VERSION}-${VERSION_PACKAGE}~${COMMIT_ID}"
dpkg-buildpackage -us -uc
exit
```

The plugin will be available in /tmp/plugins/femon
