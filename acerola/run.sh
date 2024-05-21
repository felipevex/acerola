haxe example.hxml                   && \
haxe test-api-acerola.hxml          && \
haxe test-api-acerola.hxml


bash -c "node ./build/acerola/api/api.js" &
NODE_PID=$!
echo "Servidor iniciado em: $NODE_PID"


# run server tests
node ./build/acerola/test/unit.js           && \
java -jar ./build/acerola/test/api/AcerolaApiTest.jar

echo "Kill node server at PID: $NODE_PID"
kill $NODE_PID &

