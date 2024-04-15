// Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package posixsignal

import (
	"syscall"
	"testing"
	"time"

	"github.com/Chever-John/cas/pkg/shutdown"
)

type startShutdownFunc func(sm shutdown.ShutdownManager)

func (f startShutdownFunc) StartShutdown(sm shutdown.ShutdownManager) {
	f(sm)
}

func (f startShutdownFunc) ReportError(err error) {
}

func (f startShutdownFunc) AddShutdownCallback(shutdownCallback shutdown.ShutdownCallback) {
}

func waitSig(t *testing.T, c <-chan int) {
	t.Helper()

	select {
	case <-c:

	case <-time.After(1 * time.Second):
		t.Error("Timeout waiting for StartShutdown.")
	}
}

func TestStartShutdownCalledOnDefaultSignals(t *testing.T) {
	t.Parallel()

	c := make(chan int, 100)

	psm := NewPosixSignalManager()
	err := psm.Start(startShutdownFunc(func(sm shutdown.ShutdownManager) {
		c <- 1
	}))
	if err != nil {
		return
	}

	time.Sleep(time.Millisecond)

	err = syscall.Kill(syscall.Getpid(), syscall.SIGINT)
	if err != nil {
		return
	}

	waitSig(t, c)

	err = psm.Start(startShutdownFunc(func(sm shutdown.ShutdownManager) {
		c <- 1
	}))
	if err != nil {
		return
	}

	time.Sleep(time.Millisecond)

	err = syscall.Kill(syscall.Getpid(), syscall.SIGTERM)
	if err != nil {
		return
	}

	waitSig(t, c)
}

func TestStartShutdownCalledCustomSignal(t *testing.T) {
	t.Parallel()

	c := make(chan int, 100)

	psm := NewPosixSignalManager(syscall.SIGHUP)
	err := psm.Start(startShutdownFunc(func(sm shutdown.ShutdownManager) {
		c <- 1
	}))
	if err != nil {
		return
	}

	time.Sleep(time.Millisecond)

	err = syscall.Kill(syscall.Getpid(), syscall.SIGHUP)
	if err != nil {
		return
	}

	waitSig(t, c)
}
