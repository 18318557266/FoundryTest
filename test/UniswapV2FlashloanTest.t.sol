// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "../lib/forge-std/src/Test.sol";
import {IWETH} from "../src/flashloan/Lib.sol";
import {UniswapV2Flashloan} from "../src/flashloan/UniswapV2Flashloan.sol";

address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
address constant UNISWAP_V2_FACTORY =
0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
contract UniswapV2FlashloanTest is Test{
    IWETH private weth = IWETH(WETH);

    UniswapV2Flashloan private flashloan;

    function setUp() public {
        flashloan = new UniswapV2Flashloan(UNISWAP_V2_FACTORY,DAI,WETH);
    }

    function testFlashloan() public {
        //换weth 并转入flashloan合约用做手续费
        weth.deposit{value : 1e18}();
        weth.transfer(address(flashloan),1e18);
        //闪电借贷金额
        uint amountToBorrow = 100 * 1e18;
        flashloan.flashloan(amountToBorrow);
    }

    function testFlashloanFail() public {
        //换weth 并转入flashloan合约用做手续费
        weth.deposit{value : 1e18}();
        //手续费不够的
        weth.transfer(address(flashloan),3e17);
        //闪电借贷金额
        uint amountToBorrow = 100 * 1e18;
        //用来预期回滚 抛异常行为
        vm.expectRevert();
        flashloan.flashloan(amountToBorrow);
    }
}