num=$(hostname | awk -F 'miner' '{print $NF}') && sed -i "s/1116711d3000/1116711d30${num}/g" /scratch/mainnet/f01731371/sectorstore.json
