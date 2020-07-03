# Bitcoind for docker

## 需求環境

1. docker
2. docker-compose

## Authentication

請參閱`config/bitcoin.conf`中的`rpcuser`跟`rpcpassword`

如果要部署公鏈節點，請替換成高強度的`rpcuser`跟`rpcpassword`

## 公鏈

### 說明

1. 初次啟動依機器規格與公鏈當前區塊大小，需同步3~7天不等
2. 節點交換資料的Port為`8333`，開放全域可以加快資料同步速度
3. RPC Port為`8332`，考慮安全性請勿對外開放

### 啟動`Mainnet`節點

```bash
docker-compose up -d mainnet
```

## 測試鏈

### 說明

1. 測試鏈為`test3`
2. 節點交換資料的Port為`18333`，開放全域可以加快資料同步速度
3. RPC Port為`18332`，考慮安全性請勿對外開放

### 啟動`Testnet`節點

```bash
docker-compose up -d testnet
```

## 私鏈

### 說明

1. 此私鏈作為本機測試使用，不提供對外的連線
2. 節點交換資料的Port為`18444`，不提供對外的連線
3. RPC Port為`18443`，不提供對外的連線

### 啟動`Privnet`節點

```bash
docker-compose up -d privnet
```

## 其他指令

### 重啟節點

``` bash
docker-compose restart
```

### 查看Log

```bash
docker-compose logs -f
```

### 關閉節點

```bash
docker-compose down
```
