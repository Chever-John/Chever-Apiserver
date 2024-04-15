# Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
# Use of this source code is governed by a MIT style
# license that can be found in the LICENSE file.

# quite an "unused variable" warning from shellcheck and
# also document your code
function cas::util::sourced_variable {
  true
}

cas::util::sortable_date() {
  date "+%Y%m%d-%H%M%S"
}

