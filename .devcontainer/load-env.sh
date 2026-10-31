# Load the API keys from .env (if the file exists) into the current shell.
# Used by start-app.sh and by every new terminal in the codespace. Works in bash and zsh.
# Tolerates stray spaces, quotes and Windows line endings around the values.
if [ -f "${1:-.}/.env" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line=$(printf %s "$line" | tr -d '\r')
    case "$line" in ''|\#*) continue ;; esac
    key=$(printf %s "${line%%=*}" | tr -d ' ')
    value=$(printf %s "${line#*=}" | sed "s/^[[:space:]\"']*//; s/[[:space:]\"']*\$//")
    [ -n "$value" ] && export "$key=$value"
  done < "${1:-.}/.env"
  unset line key value
fi
