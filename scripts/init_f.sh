num=$(hostname | awk -F 'miner' '{print $NF}') && sudo sed -i s/357b2a3cb400/357b2a3cb${num}/g /scratch/calibnet/f1666666/sectorstore.json
