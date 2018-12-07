docker rm quacc
docker build -t quacc .
docker run --name quacc quacc
ID=$(docker ps -aqf "name=quacc")
docker cp $ID:/app/report.html .
docker cp $ID:/app/bitcoin/lcov/ bitcoin/
docker cp $ID:/app/bitcoincash/lcov/ bitcoincash/
docker cp $ID:/app/dash/lcov/ dash/
docker cp $ID:/app/ethereum/lcov/ ethereum/
docker cp $ID:/app/monero/lcov/ monero/
docker cp $ID:/app/litecoin/lcov/ litecoin/
docker cp $ID:/app/qtum/lcov/ qtum/
docker cp $ID:/app/zcash/lcov/ zcash/
