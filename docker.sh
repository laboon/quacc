docker rm quacc
docker build -t quacc .
docker run --name quacc quacc
ID=$(docker ps -aqf "name=quacc")
docker cp $ID:/app/report.html .
docker cp -r $ID:/app/bitcoin/lcov/ bitcoin/
docker cp -r $ID:/app/bitcoincash/lcov/ bitcoincash/
docker cp -r $ID:/app/dash/lcov/ dash/
docker cp -r $ID:/app/monero/lcov/ monero/
docker cp -r $ID:/app/litecoin/lcov/ litecoin/
docker cp -r $ID:/app/zcash/lcov/ zcash/
