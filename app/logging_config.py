"""
Structured logging configuration using loguru
Provides consistent logging across the application
"""
import sys
import os
from loguru import logger
from pathlib import Path

# Remove default logger
logger.remove()

# Get log level from environment
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()
LOG_DIR = Path("logs")
LOG_DIR.mkdir(exist_ok=True)

# Define log format
LOG_FORMAT = (
    "<green>{time:YYYY-MM-DD HH:mm:ss}</green> | "
    "<level>{level: <8}</level> | "
    "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> | "
    "<level>{message}</level>"
)

# Console logging (stderr)
logger.add(
    sys.stderr,
    format=LOG_FORMAT,
    level=LOG_LEVEL,
    colorize=True,
    backtrace=True,
    diagnose=True
)

# File logging (rotating)
logger.add(
    LOG_DIR / "app_{time:YYYY-MM-DD}.log",
    format=LOG_FORMAT,
    level=LOG_LEVEL,
    rotation="00:00",  # Rotate at midnight
    retention="30 days",  # Keep logs for 30 days
    compression="zip",  # Compress old logs
    backtrace=True,
    diagnose=True
)

# Error file (separate file for errors only)
logger.add(
    LOG_DIR / "errors_{time:YYYY-MM-DD}.log",
    format=LOG_FORMAT,
    level="ERROR",
    rotation="00:00",
    retention="90 days",
    compression="zip",
    backtrace=True,
    diagnose=True
)

__all__ = ["logger"]

