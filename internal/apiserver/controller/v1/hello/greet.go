// Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package hello

import (
	"github.com/gin-gonic/gin"

	"github.com/Chever-John/cas/pkg/log"
)

func (hello *HelloerController) Greet(c *gin.Context) {
	log.Info("hello world!")
	c.JSON(200, gin.H{
		"message": "hello world!",
	})
}
