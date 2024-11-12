# Eoracle-node Incentived
![Banner](https://blog.eoracle.io/content/images/size/w2000/2024/09/eOracle-Universe.png)

## 🖥 Hardware Requirements

| Component | Minimum Specifications | Recommended Specifications |
|-----------|----------------------|---------------------------|
| CPU | 2 Cores | 4 Cores |
| RAM | 4 GB | 8 GB |
| Storage | 100 GB SSD | 200 GB SSD |
| Network | 1 Mbps | 10 Mbps |


## 💰 Faucet yang harus disiapkan
* For Testnet (Holesky): Only testnet ETH needed


## ⚡️Quick Installation
```bash
wget https://raw.githubusercontent.com/dwisetyawan00/eoracle-node/main/eoracle-install.sh
chmod +x eoracle-install.sh
./eoracle-install.sh
```
- pilih 1 untuk menginstall dependencies yang dibutuhkan
- lalu pilih 2 untuk setup dan menjalankan node
- bisa custom private rpc / biarkan untuk default


## 📝 OPTIONAL 
### Command jika anda butuhkan
### 🟡 Restart Node
```bash
sudo docker-compose -f "$HOME/Eoracle-operator-setup/data-validator/" down && \
sudo docker-compose -f "$HOME/Eoracle-operator-setup/data-validator/" up -d
```

### 🔴 Shutdown / disable node
```bash
sudo docker-compose -f "$HOME/Eoracle-operator-setup/data-validator/" down
```

## ⚠️❗️Hapus Node
```bash
sudo docker-compose -f "$HOME/Eoracle-operator-setup/data-validator/" down && rm -r $HOME/Eoracle-operator-setup
```
```bash
wget https://raw.githubusercontent.com/dwisetyawan00/eoracle-node/main/cleanup.sh && chmod +x cleanup.sh && ./cleanup.sh
```

### *DONE*
															
<div align="center">
  
  # ✨ SALAM JEPE ✨
  
</div>

## <div align="center">Powered by : </div>
<p align="center">
  <img src="https://raw.githubusercontent.com/dwisetyawan00/logo/refs/heads/main/au_ah_transparant.png" width="300" align="center" />
</p>

<div align="center">
  
  ## 💦 techzs 💦
  
</div>
