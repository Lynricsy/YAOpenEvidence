"""运行期配置。

只管 HTTP/任务层自己的东西；LLM 地址、密钥、模型名沿用 core 的
LLM_BASE / LOCAL_QWEN_KEY / LLM_MODEL 环境变量（见 ask.py），不在这里重复定义，
否则 CLI 与 API 会各读一套配置而指向不同的模型。
"""
from __future__ import annotations

import os
from pathlib import Path

from pydantic import field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

from picos_paths import VAR_DIR


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="YAOE_", env_file=".env", extra="ignore")

    redis_url: str = "redis://127.0.0.1:6379/0"
    database_url: str = ""                      # 空 -> sqlite:///{VAR_DIR}/api.sqlite3
    api_keys_file: Path = Path("api_keys.toml")
    auth_disabled: bool = False
    cors_origins: list[str] = []

    host: str = "127.0.0.1"
    port: int = 8765

    worker_max_jobs: int = 1                    # 单 GPU：默认串行跑问答任务
    job_timeout_s: int = 1800
    max_active_jobs_per_key: int = 2
    events_ttl_s: int = 604800                  # Redis 事件流保留 7 天
    events_maxlen: int = 2000

    @field_validator("cors_origins", mode="before")
    @classmethod
    def _split_origins(cls, v: object) -> object:
        """允许 `YAOE_CORS_ORIGINS=http://a,http://b`，不必写 JSON 数组。"""
        if isinstance(v, str) and not v.strip().startswith("["):
            return [x.strip() for x in v.split(",") if x.strip()]
        return v

    @model_validator(mode="after")
    def _default_database_url(self) -> Settings:
        if not self.database_url:
            os.makedirs(VAR_DIR, exist_ok=True)
            self.database_url = f"sqlite:///{os.path.join(VAR_DIR, 'api.sqlite3')}"
        return self

    @property
    def is_sqlite(self) -> bool:
        return self.database_url.startswith("sqlite")


settings = Settings()


def get_settings() -> Settings:
    return settings
