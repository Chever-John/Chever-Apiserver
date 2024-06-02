// Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package main

//go:generate swagger generate spec -o ../../api/swagger/swagger.yaml --scan-models

import (
	_ "github.com/Chever-John/cas/api/swagger/docs"
	"github.com/Chever-John/cas/internal/apiserver"
)

// apiserver is the api server for the whole service.
// It is responsible for serving the platform RESTful resource management.
func main() {
	apiserver.NewApp("cas-apiserver").Run()
}
