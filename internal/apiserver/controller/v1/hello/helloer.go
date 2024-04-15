// Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package hello

import (
	srvv1 "github.com/Chever-John/cas/internal/apiserver/service/v1"
)

type HelloerController struct {
	srv srvv1.Service
}

// NewHelloerController creates a helloer handler.
func NewHelloerController() *HelloerController {
	return &HelloerController{
		srv: srvv1.NewService(),
	}
}
