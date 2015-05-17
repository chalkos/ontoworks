FROM scratch
MAINTAINER The CentOS Project <cloud-ops@centos.org>
ADD centos-7systemd.tar.xz /


# Volumes for systemd
# VOLUME ["/run", "/tmp"]

# Environment for systemd
# ENV container=docker

# For systemd usage this changes to /usr/sbin/init
# Keeping it as /bin/bash for compatability with previous
CMD ["/bin/bash"]
