function dotenv__read {
  local var_name="$1"
  grep "^$var_name" < .env | cut -d'=' -f2 | head -1
}
