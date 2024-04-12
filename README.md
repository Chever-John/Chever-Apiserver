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
