// Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package main

import (
	"github.com/Chever-John/cas/pkg/log"
)

func main() {
	defer log.Flush()

	log.V(0).Info("This is a V level message")
	log.V(0).Infow("This is a V level message with fields", "X-Request-ID", "7a7b9f24-4cae-4b2a-9464-69088b45b904")
}
