FROM ubuntu:26.04 AS source

ADD --checksum=sha256:41be6126a30532715a14e68a62a31f7e8c9dc123f5477110113c04e37a842f09 https://download-installer.cdn.mozilla.net/pub/thunderbird/releases/153.0.3/linux-x86_64/en-US/thunderbird-153.0.3.tar.xz /tmp/source

RUN apt-get update && \
    apt-get install -y --no-install-recommends xz-utils && \
    mkdir -p /out && \
    tar -xJf /tmp/source --strip-components=1 -C /out

FROM ghcr.io/containerpak/gtk3:main

COPY --from=source /out /opt/thunderbird

RUN apt-get update && \
    apt-get install -y --no-install-recommends libdbus-glib-1-2 libxt6 && \
    mkdir -p /usr/share/applications && \
    ln -s /opt/thunderbird/thunderbird /usr/bin/thunderbird && \
    install -Dm644 /opt/thunderbird/chrome/icons/default/default128.png /usr/share/icons/hicolor/128x128/apps/thunderbird.png && \
    printf '[Desktop Entry]\nName=Thunderbird\nExec=thunderbird %%u\nIcon=thunderbird\nType=Application\nCategories=Network;Email;\nMimeType=x-scheme-handler/mailto;\n' > /usr/share/applications/thunderbird.desktop && \
    cpak-clean-junk
