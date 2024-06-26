FROM ubuntu:22.04
RUN apt-get update && apt-get install -y init && apt-get clean all
#另外我还希望创建的镜像能够安装ssh并允许密码登录
RUN apt-get update && apt-get install -y openssh-server nano lsof
#定义时区参数
ENV TZ=Asia/Shanghai
#设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo '$TZ' > /etc/timezone

RUN apt-get install -y \
    git autoconf automake libtool make libreadline-dev texinfo \
    pkg-config libpam0g-dev libjson-c-dev bison flex \
    libc-ares-dev python3-dev python3-sphinx \
    install-info build-essential libsnmp-dev perl \
    libcap-dev libelf-dev libunwind-dev \
    protobuf-c-compiler libprotobuf-c-dev
RUN apt-get install -y cmake libpcre2-dev
RUN cd /
COPY libyang /libyang
# RUN cd libyang
# RUN mkdir build 
# RUN cd build
# RUN cmake --install-prefix /usr \
#     -D CMAKE_BUILD_TYPE:String="Release" ..
# RUN make
# RUN make install
RUN groupadd -r -g 92 frr
RUN groupadd -r -g 85 frrvty
RUN adduser --system --ingroup frr --home /var/run/frr/ \
    --gecos "FRR suite" --shell /sbin/nologin frr
RUN usermod -a -G frrvty frr
COPY frr /frr
# RUN git clone https://github.com/frrouting/frr.git frr
# RUN cd frr
# RUN ./bootstrap.sh
# RUN ./configure \
#     --prefix=/usr \
#     --includedir=\${prefix}/include \
#     --bindir=\${prefix}/bin \
#     --sbindir=\${prefix}/lib/frr \
#     --libdir=\${prefix}/lib/frr \
#     --libexecdir=\${prefix}/lib/frr \
#     --sysconfdir=/etc \
#     --localstatedir=/var \
#     --with-moduledir=\${prefix}/lib/frr/modules \
#     --enable-configfile-mask=0640 \
#     --enable-logfile-mask=0640 \
#     --enable-snmp=agentx \
#     --enable-multipath=64 \
#     --enable-user=frr \
#     --enable-group=frr \
#     --enable-vty-group=frrvty \
#     --with-pkg-git-version \
#     --with-pkg-extra-version=-MyOwnFRRVersion
# RUN make 
# RUN make install
RUN install -m 775 -o frr -g frr -d /var/log/frr
RUN install -m 775 -o frr -g frrvty -d /etc/frr
COPY daemons.conf /etc/frr/daemons.conf
COPY daemons /etc/frr/daemons
COPY vtysh.conf /etc/frr/vtysh.conf
COPY r3-bgp /etc/frr/frr.conf
COPY frr.service /etc/systemd/system/frr.service
RUN systemctl enable frr
# RUN systemctl start frr
