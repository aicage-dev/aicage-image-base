#!/usr/bin/env bash
set -euo pipefail

if command -v apt-get >/dev/null 2>&1; then
  apt-get install -y --no-install-recommends \
    "${AICAGE_PACKAGE_DEFAULT_MYSQL_CLIENT_INSTALL:-default-mysql-client}" \
    "${AICAGE_PACKAGE_POSTGRESQL_CLIENT_INSTALL:-postgresql-client}" \
    "${AICAGE_PACKAGE_SQLITE3_INSTALL:-sqlite3}"
elif command -v dnf >/dev/null 2>&1; then
  dnf -y install \
    "${AICAGE_PACKAGE_MYSQL_INSTALL:-mysql}" \
    "${AICAGE_PACKAGE_POSTGRESQL_INSTALL:-postgresql}" \
    "${AICAGE_PACKAGE_SQLITE_INSTALL:-sqlite}"
elif command -v apk >/dev/null 2>&1; then
  # shellcheck disable=SC2086
  apk add --no-cache \
    ${AICAGE_PACKAGE_MARIADB_CLIENT_INSTALL:-mariadb-client} \
    ${AICAGE_PACKAGE_POSTGRESQL_CLIENT_INSTALL:-postgresql-client} \
    ${AICAGE_PACKAGE_SQLITE_INSTALL:-sqlite}
elif command -v pacman >/dev/null 2>&1; then
  pacman -S --noconfirm --needed \
    mariadb-clients \
    postgresql \
    sqlite
else
  echo "Unsupported package manager for database client installation" >&2
  exit 1
fi
