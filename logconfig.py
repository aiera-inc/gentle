import logging
import logging.config
from datetime import datetime
from pythonjsonlogger.jsonlogger import JsonFormatter


MAX_LOG_MSG_LEN = 10000


def configure_logging():
    log_handlers = {
        "console": {"class": "logging.StreamHandler", "formatter": "json"},
        "metrics": {"class": "logging.StreamHandler", "formatter": "metrics"},
    }

    log_handler_names = [k for k in log_handlers.keys() if k != "metrics"]

    # configure python loggers
    logging.captureWarnings(True)
    logging.config.dictConfig(
        {
            "version": 1,
            "disable_existing_loggers": True,
            "formatters": {
                "standard": {"format": "%(asctime)s [%(levelname)s] %(name)s: %(message)s"},
                "metrics": {"format": "%(message)s"},
                "json": {"()": LoggingJsonFormatter},
            },
            "handlers": log_handlers,
            "loggers": {
                "": {"level": "WARN", "handlers": log_handler_names},
                "aiera": {
                    "level": "INFO",
                    "handlers": log_handler_names,
                    "propagate": False,
                },
                "luigi": {"level": "WARN", "handlers": log_handler_names, "propagate": False},
                "luigi-interface": {"level": "WARN", "handlers": log_handler_names, "propagate": False},
                "py.warnings": {"Level": "WARN", "handlers": log_handler_names, "propagate": False},
                "schedule": {"level": "INFO", "handlers": log_handler_names, "propagate": False},
                # "sqlalchemy.engine": {"level": "INFO", "handlers": log_handler_names, "propagate": False},
            },
        }
    )


class LoggingJsonFormatter(JsonFormatter):
    def add_fields(self, log_record, record, message_dict):
        super(LoggingJsonFormatter, self).add_fields(log_record, record, message_dict)

        # make sure the message length does not exceed max msg
        message = log_record.get("message", "")
        if len(message) > MAX_LOG_MSG_LEN:
            log_record["message"] = message[0:MAX_LOG_MSG_LEN] + f"...[truncated from {len(message)}]"

        log_record["service"] = "gentle"
        log_record["logger.name"] = record.name

        if isinstance(record.args, dict):
            for key, val in record.args.items():
                log_record[key] = val

        if not log_record.get("timestamp"):
            # this doesn't use record.created, so it is slightly off
            now = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S.%fZ")
            log_record["timestamp"] = now
        if log_record.get("level"):
            log_record["level"] = log_record["level"].upper()
        else:
            log_record["level"] = record.levelname
