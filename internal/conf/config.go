package conf

import (
	"github.com/flyge1995/kratos-extend/config"
	"github.com/flyge1995/kratos-extend/log/zap"
)

type Config struct {
	Http config.HTTP `mapstructure:"http"`
	Grpc config.GRPC `mapstructure:"grpc"`
	Log  zap.Config  `mapstructure:"log"`
}
