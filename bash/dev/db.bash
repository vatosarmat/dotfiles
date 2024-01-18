function db__postgres_get_json {
  psql -t moyclass <<< "select params->'emp_telegram_bot' from managers where id=228025"

  # How to fetch undecorated value from psql, so no need in jq?
  psql -t moyclass <<< "select json_agg(tg_text) from mailing_templates where system_code='emp_stopped_visiting' and lang='en';" | jq -r '.[]'

  jq -r '.templates[] | select(.code=="emp_stopped_visiting" and .lang=="ru").text' bin/updates/2148_templates.json

}

function db__mysql_reset {

  local user password db_name seed_file
  local OPTIND OPTARG OPTERR opt
  while getopts "u:p:s:" opt; do
    case $opt in
      [u])
        user="$OPTARG"
        ;;
      [p])
        password="$OPTARG"
        ;;
      [s])
        seed_file="$OPTARG"
        ;;
      *) ;;
    esac
  done
  shift $((OPTIND - 1))

  db_name="$1"
  if [[ ! "$db_name" ]]; then
    echo "db name expected as a free argument" >&2
    return 1
  fi
  shift

  if [[ ! "$user" ]]; then
    user="$db_name"
  fi

  if [[ ! "$password" ]]; then
    password="123"
  fi

  mysql << SQL
DROP USER IF EXISTS '$user'@'localhost';
DROP DATABASE IF EXISTS $db_name;

CREATE USER '$user'@'localhost' IDENTIFIED WITH mysql_native_password BY '$password';
CREATE DATABASE $db_name;
GRANT ALL PRIVILEGES ON $db_name.* TO '$user'@'localhost';
SQL

  if [[ "$seed_file" ]]; then
    mysql --user="$user" --password="$password" "$db_name" < "$seed_file"
  fi

}

function db__postgres_reset {

  local user password db_name seed_file
  local OPTIND OPTARG OPTERR opt
  while getopts "u:p:s:" opt; do
    case $opt in
      [u])
        user="$OPTARG"
        ;;
      [p])
        password="$OPTARG"
        ;;
      [s])
        seed_file="$OPTARG"
        ;;
      *) ;;
    esac
  done
  shift $((OPTIND - 1))

  db_name="$1"
  if [[ ! "$db_name" ]]; then
    echo "db name expected as a free argument" >&2
    return 1
  fi
  shift

  if [[ ! "$user" ]]; then
    user="$db_name"
  fi

  if [[ ! "$password" ]]; then
    password="123"
  fi

  psql << SQL
DROP DATABASE IF EXISTS "$db_name";
DROP OWNED BY "$user" CASCADE;
DROP ROLE IF EXISTS "$user";

CREATE ROLE "$user" WITH ENCRYPTED PASSWORD '$password' LOGIN;
CREATE DATABASE "$db_name" WITH OWNER "$user";
SQL

  if [[ "$seed_file" ]]; then
    psql --user="$user" --password="$password" "$db_name" < "$seed_file"
  fi
}

# function _db__bitrix_settings_read {
# Cast array to json and read with jq
#   local var_name="\$DB$1"
#   php -r "print_r((require 'bitrix/.settings.php')['connections']['value']['default']);"
#   php -r "$(grep "^$var_name" < bitrix/php_interface/dbconn.php)echo $var_name;"
# }

function db__bitrix_reset {
  if [[ ! -r "bitrix/php_interface/dbconn.php" ]]; then
    echo "bitrix/php_interface/dbconn.php file not readable" >&2
    return 1
  fi

  local name="$(_db__bitrix_dbconn_read Name)"
  local login="$(_db__bitrix_dbconn_read Login)"
  local password="$(_db__bitrix_dbconn_read Password)"

  # read -r -d '' sql << SQL
  mysql << SQL
DROP USER IF EXISTS '$login'@'localhost';
DROP DATABASE IF EXISTS $name;

CREATE USER '$login'@'localhost' IDENTIFIED WITH mysql_native_password BY '$password';
CREATE DATABASE $name;
GRANT ALL PRIVILEGES ON $name.* TO '$login'@'localhost';
SQL
  # GRANT SESSION_VARIABLES_ADMIN ON *.* to 'p3010_admin'@'localhost';

  # echo -e "$sql"

  if (($# > 0)); then
    local seed_file="$1"
    echo "running $seed_file"
    mysql --user="$login" --password="$password" "$name" < "$seed_file"
  fi
}
