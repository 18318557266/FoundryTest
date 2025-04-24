// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Lib.sol";

interface IUniswapV2Callee {

    function uniswapV2Call(address sender,uint amount0,uint amount1,bytes calldata data) external;

}

contract UniswapV2Flashloan is IUniswapV2Callee{

    //uniswap_v2_factory 地址 正常来说需要在构造方法上作为入参
    address private immutable UNISWAP_V2_FACTORY;

    address private immutable DAI;
    address private immutable WETH;

    IUniswapV2Factory private immutable factory;

    IERC20 private immutable weth;

    IUniswapV2Pair private immutable pair;

    constructor(address _factory,address _adi,address _weth) {
        UNISWAP_V2_FACTORY = _factory;
        factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);
        DAI = _adi;
        WETH = _weth;
        weth = IERC20(WETH);
        pair = IUniswapV2Pair(factory.getPair(DAI, WETH));
    }


    function flashloan(uint wethAmount) external {
        bytes memory data = abi.encode(WETH,wethAmount);
        //借WETH 数量为wethAmount 到这个合约
        pair.swap(0, wethAmount, address(this), data);
    }

    //调用pair.swap后的回调函数
    function uniswapV2Call(address sender,uint amount0,uint amount1,bytes calldata data) external{
        address token0 = IUniswapV2Pair(msg.sender).token0(); //获取token0地址
        address token1 = IUniswapV2Pair(msg.sender).token1(); //获取token1地址
        assert(msg.sender == factory.getPair(token0, token1));

        (address tokenBorrow,uint256 wethAmount) = abi.decode(data, (address,uint256));
        require(tokenBorrow == WETH, "token borrow !=");
        require(wethAmount > 0,"");
        
        //套利操作

        //计算利息费用 fee/(amount + fee) = 3/100
        //加1为了向上取整
        uint fee = (amount1 * 3)/997 + 1;
        uint amountToRepay = amount1 + fee;
        weth.transfer(address(pair), amountToRepay);
    }   
}