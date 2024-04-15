# 修复 golangci-lint

今天突然想修复一下这个，然后花了挺久，终于全部修复完了，这段工作还是挺有意思的。

我遇到过一种情况，当我 golangci-lint 修复好了，CodeQL 又不行了。原因是我将 go.mod 的 go version 设置为了 1.22 但是 CodeQL 无法识别，所以只好在 CodeQL 的 yaml 配置中添加了详细的 Go 版本。