# Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
# Use of this source code is governed by a MIT style
# license that can be found in the LICENSE file.

make build PLATFORM="linux_amd64"
sleep 1
./_output/platforms/linux/amd64/cas-apiserver
