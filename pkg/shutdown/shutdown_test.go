// Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package shutdown

import (
	"errors"
	"testing"
	"time"
)

const (
	TestSM  = "test-sm"
	MyError = "my-error"
)

type SMShutdownStartFunc func() error

func (f SMShutdownStartFunc) GetName() string {
	return TestSM
}

func (f SMShutdownStartFunc) ShutdownStart() error {
	return f()
}

func (f SMShutdownStartFunc) ShutdownFinish() error {
	return nil
}

func (f SMShutdownStartFunc) Start(gs GSInterface) error {
	return nil
}

type SMFinishFunc func() error

func (f SMFinishFunc) GetName() string {
	return TestSM
}

func (f SMFinishFunc) ShutdownStart() error {
	return nil
}

func (f SMFinishFunc) ShutdownFinish() error {
	return f()
}

func (f SMFinishFunc) Start(gs GSInterface) error {
	return nil
}

type SMStartFunc func() error

func (f SMStartFunc) GetName() string {
	return TestSM
}

func (f SMStartFunc) ShutdownStart() error {
	return nil
}

func (f SMStartFunc) ShutdownFinish() error {
	return nil
}

func (f SMStartFunc) Start(gs GSInterface) error {
	return f()
}

func TestCallbacksGetCalled(t *testing.T) {
	t.Parallel()

	gs := New()

	c := make(chan int, 100)
	for i := 0; i < 15; i++ {
		gs.AddShutdownCallback(ShutdownFunc(func(string) error {
			c <- 1

			return nil
		}))
	}

	gs.StartShutdown(SMFinishFunc(func() error {
		return nil
	}))

	if len(c) != 15 {
		t.Error("Expected 15 elements in channel, got ", len(c))
	}
}

func TestStartGetsCalled(t *testing.T) {
	t.Parallel()

	gs := New()

	c := make(chan int, 100)
	for i := 0; i < 15; i++ {
		gs.AddShutdownManager(SMStartFunc(func() error {
			c <- 1

			return nil
		}))
	}

	err := gs.Start()
	if err != nil {
		return
	}

	if len(c) != 15 {
		t.Error("Expected 15 Start to be called, got ", len(c))
	}
}

func TestStartErrorGetsReturned(t *testing.T) {
	t.Parallel()

	gs := New()

	gs.AddShutdownManager(SMStartFunc(func() error {
		return errors.New(MyError)
	}))

	err := gs.Start()
	if err == nil || err.Error() != MyError {
		t.Error("Shutdown did not return my-error, got ", err)
	}
}

func TestShutdownStartGetsCalled(t *testing.T) {
	t.Parallel()

	c := make(chan int, 100)
	gs := New()

	gs.AddShutdownCallback(ShutdownFunc(func(string) error {
		time.Sleep(5 * time.Millisecond)

		return nil
	}))

	gs.StartShutdown(SMShutdownStartFunc(func() error {
		c <- 1

		return nil
	}))

	if len(c) != 1 {
		t.Error("Expected 1 ShutdownStart, got ", len(c))
	}
}

func TestShutdownFinishGetsCalled(t *testing.T) {
	t.Parallel()
	c := make(chan int, 100)
	gs := New()

	gs.AddShutdownCallback(ShutdownFunc(func(string) error {
		time.Sleep(5 * time.Millisecond)

		return nil
	}))

	gs.StartShutdown(SMFinishFunc(func() error {
		c <- 1

		return nil
	}))

	if len(c) != 1 {
		t.Error("Expected 1 ShutdownFinish, got ", len(c))
	}
}

func TestErrorHandlerFromStartShutdown(t *testing.T) {
	t.Parallel()

	c := make(chan int, 100)
	gs := New()

	gs.SetErrorHandler(ErrorFunc(func(err error) {
		if err.Error() == MyError {
			c <- 1
		}
	}))

	gs.StartShutdown(SMShutdownStartFunc(func() error {
		return errors.New(MyError)
	}))

	if len(c) != 1 {
		t.Error("Expected 1 error from ShutdownStart, got ", len(c))
	}
}

func TestErrorHandlerFromFinishShutdown(t *testing.T) {
	t.Parallel()
	c := make(chan int, 100)
	gs := New()

	gs.SetErrorHandler(ErrorFunc(func(err error) {
		if err.Error() == MyError {
			c <- 1
		}
	}))

	gs.StartShutdown(SMFinishFunc(func() error {
		return errors.New(MyError)
	}))

	if len(c) != 1 {
		t.Error("Expected 1 error from ShutdownFinish, got ", len(c))
	}
}

func TestErrorHandlerFromCallbacks(t *testing.T) {
	t.Parallel()

	c := make(chan int, 100)
	gs := New()

	gs.SetErrorHandler(ErrorFunc(func(err error) {
		if err.Error() == MyError {
			c <- 1
		}
	}))

	for i := 0; i < 15; i++ {
		gs.AddShutdownCallback(ShutdownFunc(func(string) error {
			return errors.New(MyError)
		}))
	}

	gs.StartShutdown(SMFinishFunc(func() error {
		return nil
	}))

	if len(c) != 15 {
		t.Error("Expected 15 error from ShutdownCallbacks, got ", len(c))
	}
}

func TestErrorHandlerDirect(t *testing.T) {
	t.Parallel()

	c := make(chan int, 100)
	gs := New()

	gs.SetErrorHandler(ErrorFunc(func(err error) {
		if err.Error() == MyError {
			c <- 1
		}
	}))

	gs.ReportError(errors.New(MyError))

	if len(c) != 1 {
		t.Error("Expected 1 error from ReportError call, got ", len(c))
	}
}

func TestShutdownManagerName(t *testing.T) {
	t.Parallel()

	c := make(chan int, 100)
	gs := New()

	gs.AddShutdownCallback(ShutdownFunc(func(shutdownManager string) error {
		if shutdownManager == TestSM {
			c <- 1
		}

		return nil
	}))

	gs.StartShutdown(SMFinishFunc(func() error {
		return nil
	}))

	if len(c) != 1 {
		t.Error("Expected shutdownManager to be 'test-sm'.")
	}
}
