// Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package apiserver

import (
	"github.com/gin-gonic/gin"

	"github.com/Chever-John/cas/internal/apiserver/controller/v1/hello"
)

func initRouter(g *gin.Engine) {
	installMiddleware(g)
	installController(g)
}

func installMiddleware(g *gin.Engine) {
}

func installController(g *gin.Engine) *gin.Engine {
	// v1 handlers, requiring authentication
	v1 := g.Group("/v1")
	{
		// helloer RESTful resource
		helloerv1 := v1.Group("/helloers")
		{
			helloerController := hello.NewHelloerController()

			helloerv1.GET("", helloerController.Greet)
		}
	}

	return g
}
