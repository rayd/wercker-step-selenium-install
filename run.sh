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

whichjava=`which java`
debug "Java install: $whichjava"

# Start Selenium and wait for port 4444 to become available
start-stop-daemon --start --quiet --pidfile /tmp/selenium.pid --make-pidfile --background --exec java -jar "${CACHE_DIR}/${JAR_FILE}"
debug "Starting up selenium with ${CACHE_DIR}/${JAR_FILE}."
count=0
nc -vz localhost 4444
res="$?"
while [[ "$res" != "0" && $count -lt 60 ]]; do
    debug "Selenium not started yet..."
    sleep 1
    count=$((count+1))
    nc -vz localhost 4444
    res="$?"
done

success "Selenium started up successfully."
