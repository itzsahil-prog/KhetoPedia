"""
Structured logging configuration for Khetopedia backend.

Uses Python's standard `logging` module with a JSON formatter for production
and a human-friendly formatter for local development.

Usage:
    from app.core.logging_config import configure_logging
    configure_logging()          # call once at startup
    
    import logging
    logger = logging.getLogger(__name__)
    logger.info("Something happened", extra={"user_id": "..."})
"""
import json
import logging
import sys
from datetime import datetime, timezone


class JSONFormatter(logging.Formatter):
    """
    Emit each log record as a single-line JSON object.
    Suitable for log aggregators (CloudWatch, Elasticsearch, Loki, etc.).
    """

    # Fields extracted directly from the LogRecord
    _CORE_FIELDS = {
        "name", "levelname", "pathname", "lineno",
        "funcName", "exc_info", "exc_text", "stack_info",
    }

    def format(self, record: logging.LogRecord) -> str:
        payload: dict = {
            "timestamp": datetime.fromtimestamp(record.created, tz=timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "line": record.lineno,
        }

        # Attach exception info when present
        if record.exc_info:
            payload["exc_info"] = self.formatException(record.exc_info)

        # Forward any extra= kwargs that aren't standard LogRecord fields
        for key, value in record.__dict__.items():
            if key not in logging.LogRecord.__dict__ and key not in self._CORE_FIELDS:
                try:
                    json.dumps(value)  # only include JSON-serialisable extras
                    payload[key] = value
                except (TypeError, ValueError):
                    payload[key] = str(value)

        return json.dumps(payload, ensure_ascii=False)


class DevFormatter(logging.Formatter):
    """
    Coloured, human-readable formatter for local development.
    """
    _COLOURS = {
        "DEBUG":    "\033[36m",   # cyan
        "INFO":     "\033[32m",   # green
        "WARNING":  "\033[33m",   # yellow
        "ERROR":    "\033[31m",   # red
        "CRITICAL": "\033[35m",   # magenta
    }
    _RESET = "\033[0m"

    def format(self, record: logging.LogRecord) -> str:
        colour = self._COLOURS.get(record.levelname, "")
        reset = self._RESET
        ts = datetime.fromtimestamp(record.created, tz=timezone.utc).strftime("%H:%M:%S")
        base = f"{colour}{ts} {record.levelname:<8}{reset} [{record.name}] {record.getMessage()}"
        if record.exc_info:
            base += "\n" + self.formatException(record.exc_info)
        return base


def configure_logging(json_logs: bool = False, level: str = "INFO") -> None:
    """
    Configure the root logger.

    Args:
        json_logs: Use JSON formatter when True (for production / Docker).
                   Use the dev formatter when False (default).
        level:     Minimum log level string, e.g. "DEBUG", "INFO", "WARNING".
    """
    formatter: logging.Formatter = (
        JSONFormatter() if json_logs else DevFormatter()
    )

    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(formatter)

    root = logging.getLogger()
    root.handlers.clear()
    root.addHandler(handler)
    root.setLevel(getattr(logging, level.upper(), logging.INFO))

    # Quieten noisy third-party loggers in production
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    logging.getLogger("sqlalchemy.engine").setLevel(logging.WARNING)
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("httpcore").setLevel(logging.WARNING)
