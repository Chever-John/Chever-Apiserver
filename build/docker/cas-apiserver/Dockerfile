# Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
# Use of this source code is governed by a MIT style
# license that can be found in the LICENSE file.

FROM BASE_IMAGE
LABEL maintainer="<cheverjonathan@gmail.com>"

WORKDIR /opt/cas

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
      echo "Asia/Shanghai" > /etc/timezone && \
      mkdir -p /var/log/cas

COPY cas-apiserver /opt/cas/bin/

ENTRYPOINT ["/opt/cas/bin/cas-apiserver"]
CMD ["-c", "/etc/cas/cas-apiserver.yaml"]
