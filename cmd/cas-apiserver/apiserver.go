// Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package main

import (
	"github.com/Chever-John/cas/internal/apiserver"
)

// apiserver is the api server for the whole service.
// It is responsible for serving the platform RESTful resource management.
func main() {
	apiserver.NewApp("cas-apiserver").Run()
}
