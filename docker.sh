docker rm quacc
docker build -t quacc .
docker run --name quacc quacc
ID=$(docker ps -aqf "name=quacc")
docker cp $ID:/app/report.html .