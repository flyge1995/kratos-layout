//go:build wireinject
// +build wireinject

// The build tag makes sure the stub is not built in the final build.

package main

import (
	"github.com/flyge1995/kratos-extend/danta"
	"github.com/flyge1995/kratos-extend/log/zap"
	"github.com/go-kratos/kratos-layout/internal/server"
	"github.com/go-kratos/kratos/v2"
	"github.com/google/wire"
)

// wireApp init kratos application.
func wireApp() (*kratos.App, func(), error) {
	panic(wire.Build(
		// 上下文
		danta.ContextProviderSet,

		// 配置
		inputConfig,

		// 日志
		inputLogger,
		zap.LoggerProviderSet,

		// 服务
		server.ProviderSet,

		// app
		newApp,
	))
}
