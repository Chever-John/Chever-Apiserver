// Copyright 2024 Chenwei Jiang <cheverjonathan@gmail.com>. All rights reserved.
// Use of this source code is governed by a MIT style
// license that can be found in the LICENSE file.

package log_test

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/Chever-John/cas/pkg/log"
)

func Test_Options_Validate(t *testing.T) {
	t.Parallel()

	opts := &log.Options{
		Level:            "test",
		Format:           "test",
		EnableColor:      true,
		DisableCaller:    false,
		OutputPaths:      []string{"stdout"},
		ErrorOutputPaths: []string{"stderr"},
	}

	errs := opts.Validate()
	expected := `[unrecognized level: "test" not a valid log format: "test"]`
	assert.Equal(t, expected, fmt.Sprintf("%s", errs))
}
