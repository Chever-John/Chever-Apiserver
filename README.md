# CAS(Chever-Apiserver)

A simple system for Chever.

## Run Locally

Clone the project

```bash
git clone git@github.com:Chever-John/cas.git
```

Go to the project directory

```bash
cd my-project
```

Install cas

```bash
GEN_CFG_ENV="Macos" ./scripts/generate_config.sh ./scripts/install/environment.sh ./configs/cas-apiserver.yaml > cas-apiserver.yaml
```

Start the server

```bash
go run ./cmd/cas-apiserver/apiserver.go
```

## 问题解决

遇到在根目录运行命令：

```shell
make tools.install
```

会遇到报错，如下：

```shell
===========> Installing cfssl
make[1]: /Users/cheverjohn/Workspace/golang/src/github.com/Chever-John/cas/scripts/install/install.sh: Permission denied
make[1]: *** [install.cfssl] Error 1
make: *** [tools.install.cfssl] Error 2
```

方法就是，提前加权限：

```shell
chmod +x /Users/cheverjohn/Workspace/golang/src/github.com/Chever-John/cas/scripts/install/install.sh
```

