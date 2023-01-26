## Health token

[攻击交易](https://bscscan.com/tx/0xae8ca9dc8258ae32899fe641985739c3fa53ab1f603973ac74b424e165c66ccf)
[health contract](https://bscscan.com/token/0x32b166e082993af6598a89397e82e123ca44e74e?a=0x32b166e082993af6598a89397e82e123ca44e74e#code)

### 攻击分析

攻击者通过闪电贷借出`40WBNB`，调用pancakeSwap兑换了30565652268756555675523626[health token](https://bscscan.com/address/0x32b166e082993af6598a89397e82e123ca44e74e#code)然后攻击者循环多次调用`health`的transfer函数(转账额度为0)，由于`health`拥有销毁机制每次调用都会触发销毁机制，由于销毁导致池子中的`health token`数量减少，价格就会被拉高。此时攻击者在卖出自己之前购买的`health`从而获利。

### 存在漏洞

`transfer`判断发起者不是从`pair`(池子)的话，就触发销毁机制。调用利用的是转账多次额度为0触发销毁。

```
if (block.timestamp >= pairStartTime.add(jgTime) && pairStartTime != 0) {
    //  如果发起地址不pair合约。不是从池子中交易的话。
    if (from != uniswapV2Pair) {
        uint256 burnValue = _balances[uniswapV2Pair].mul(burnFee).div(1000);
        _balances[uniswapV2Pair] = _balances[uniswapV2Pair].sub(burnValue);
        _balances[_burnAddress] = _balances[_burnAddress].add(burnValue);
        if (block.timestamp >= pairStartTime.add(jgTime)) {
            pairStartTime += jgTime;
        }
        emit Transfer(uniswapV2Pair,_burnAddress, burnValue);
        IPancakePair(uniswapV2Pair).sync();
    }
}
```

### 模拟攻击

模拟交易 wbnb -> health。此时form地址是wbnb。所以会进入transfer的销毁条件触发销毁机制。
```ts
//  如果无效在hardhat.config.ts中自行配置启动fork地址和区块
hh node --fork https://bsc-mainnet.nodereal.io/v1/<mykey> --fork-block-number 22337425
hh run examples/HealthToken/HealthToken.ts 
```
### 漏洞修复

```
if (to == uniswapV2Pair)//  只有接受者为pair的时候再去触发销毁机制。
```
