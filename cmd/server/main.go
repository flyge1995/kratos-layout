package main

import (
	"context"
	"flag"
	"github.com/flyge1995/kratos-extend/config"
	"github.com/flyge1995/kratos-extend/danta"
	"github.com/flyge1995/kratos-extend/log/zap"
	"github.com/go-kratos/kratos-layout/internal/conf"
	"github.com/go-kratos/kratos/v2"
	"github.com/go-kratos/kratos/v2/log"
	"github.com/go-kratos/kratos/v2/transport/grpc"
	"github.com/go-kratos/kratos/v2/transport/http"
	"os"
	"syscall"

	_ "go.uber.org/automaxprocs"
)

// go build -ldflags "-X main.Version=x.y.z"
var (
	// Name is the name of the compiled software.
	Name string
	// Version is the version of the compiled software.
	Version string
	// flagconf is the config flag.
	flagconf string

	id, _ = os.Hostname()
)

func init() {
	flag.StringVar(&flagconf, "conf", "configs/config.yaml", "config path, eg: -conf configs/config.yaml")
}

func inputConfig() (*conf.Config, error) {
	c := &conf.Config{}
	err := config.NewConfig().LoadEnvAndConfigFile(flagconf, c)
	if err != nil {
		return nil, err
	}
	return c, nil
}

func inputLogger(_conf *conf.Config) *zap.Config {
	z := &_conf.Log
	z.KV.ID = id
	z.KV.Version = Version
	z.KV.Name = Name
	return z
}

func newApp(ctx danta.Context, logger log.Logger, gs *grpc.Server, hs *http.Server) *kratos.App {
	helper := log.NewHelper(logger)
	return kratos.New(
		kratos.Name(Name),
		kratos.Version(Version),
		kratos.ID(id),
		kratos.Metadata(map[string]string{}),
		kratos.Logger(logger),
		kratos.Signal(syscall.SIGINT, syscall.SIGTERM),
		kratos.Context(ctx.Context),
		kratos.BeforeStart(func(ctx context.Context) error {
			helper.Info("服务器初始化完成，准备启动")
			return nil
		}),
		kratos.AfterStart(func(ctx context.Context) error {
			helper.Info("服务器启动")
			return nil
		}),
		kratos.BeforeStop(func(_ context.Context) error {
			helper.Info("服务器即将关闭")
			ctx.CancelFunc()
			return nil
		}),
		kratos.AfterStop(func(ctx context.Context) error {
			helper.Info("服务器关闭")
			return nil
		}),
		kratos.Server(
			gs,
			hs,
		),
	)
}

func main() {
	err := danta.Run(wireApp)
	if err != nil {
		panic(err)
	}
}
