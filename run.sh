if [ ! -n "$WERCKER_SELENIUM_INSTALL_JAR_FILE_URL" ]; then
  error 'Please specify jar-file-url property'
  exit 1
fi

if [ ! -n "$WERCKER_SELENIUM_INSTALL_JAR_FILE_VERSION" ]; then
  error 'Please specify jar-file-version property'
  exit 1
fi

JAR_FILE="selenium-server-standalone-${WERCKER_SELENIUM_INSTALL_JAR_FILE_VERSION}.jar"
CACHE_DIR="${WERCKER_CACHE_DIR}/wercker/selenium-server"

[ ! -d "${CACHE_DIR}" ] && mkdir -p $CACHE_DIR

if [[ ! -f "${CACHE_DIR}/${JAR_FILE}" ]]; then
  # Download Selenium Standalone Server
  debug "Downloading version ${WERCKER_SELENIUM_INSTALL_JAR_FILE_VERSION} of Selenium jar..."
  curl "${WERCKER_SELENIUM_INSTALL_JAR_FILE_URL}" -o "${CACHE_DIR}/${JAR_FILE}"
fi

if [[ -n "$WERCKER_SELENIUM_INSTALL_MD5_CHECKSUM" ]]; then
  info "Checking md5sum of downloaded JAR..."
  sum=`md5sum -b "${CACHE_DIR}/${JAR_FILE}" | cut -f1 -d' '`
  if [[ "$sum" == "$WERCKER_SELENIUM_INSTALL_MD5_CHECKSUM"]]; then
    info "Checksum verified!"
  else
    fail "Checksum was incorrect: $WERCKER_SELENIUM_INSTALL_MD5_CHECKSUM != $sum"
  fi
fi

whichjava=`which java`
debug "Java install: $whichjava"

# Start Selenium and wait for port 4444 to become available
start-stop-daemon --start --quiet --pidfile /tmp/selenium.pid --make-pidfile --background --exec /usr/bin/java -- -jar "${CACHE_DIR}/${JAR_FILE}"
debug "Starting up selenium with ${CACHE_DIR}/${JAR_FILE}."

while ! nc -vz localhost 4444; do
    count=$((count+1))
    debug "Selenium not started yet..."
    if [[ count -gt 60 ]]; then
        break
    fi
    sleep 1
done

if [[ $count -gt 60 ]]; then
    fail "Selenium did not start up."
else
    success "Selenium started up successfully."
fi
