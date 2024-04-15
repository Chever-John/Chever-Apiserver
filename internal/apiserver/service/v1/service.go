// Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package v1

type Service interface {
	Helloers() HelloerSrv
}

type service struct{}

// NewService returns Service interface.
func NewService() Service {
	return &service{}
}

func (s *service) Helloers() HelloerSrv {
	return newHelloers(s)
}
