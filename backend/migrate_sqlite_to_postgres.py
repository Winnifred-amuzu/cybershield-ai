"""One-time migration of the current SQLite database into PostgreSQL.

Run only after CYBERSHIELD_DATABASE_URL points at the target PostgreSQL database.
The source SQLite file is read-only; this script does not modify it.
"""
import sqlite3
from pathlib import Path

from sqlalchemy import text

from app.core.config import DATABASE_PATH
from app.services.database import create_database, engine


def rows(connection, table):
    connection.row_factory = sqlite3.Row
    return connection.execute(f"SELECT * FROM {table}").fetchall()


def main():
    source = Path(DATABASE_PATH)
    if not source.exists():
        raise SystemExit(f"SQLite source not found: {source}")
    if not engine.url.drivername.startswith("postgresql"):
        raise SystemExit("Set CYBERSHIELD_DATABASE_URL to a PostgreSQL URL before migrating")

    create_database()
    source_conn = sqlite3.connect(source)
    try:
        with engine.begin() as target:
            for table, columns in {
                "users": ["id", "name", "email", "password_hash", "created_at"],
                "history": ["id", "message", "source", "prediction", "confidence", "timestamp"],
                "user_history": ["id", "user_id", "message", "source", "prediction", "confidence", "timestamp"],
            }.items():
                data = rows(source_conn, table)
                if not data:
                    continue
                names = ",".join(columns)
                binds = ",".join(f":{c}" for c in columns)
                sql = text(f"INSERT INTO {table} ({names}) VALUES ({binds}) ON CONFLICT DO NOTHING")
                for row in data:
                    target.execute(sql, dict(row))
    finally:
        source_conn.close()

    print("Migration completed successfully.")


if __name__ == "__main__":
    main()
