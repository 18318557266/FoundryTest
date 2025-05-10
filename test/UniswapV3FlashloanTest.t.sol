// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {IWETH} from "../src/flashloan/Lib.sol";
import {UniswapV3Flashloan} from "../src/flashloan/UniswapV3Flashloan.sol";

address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

contract UniswapV3FlashloanTest is Test{
    IWETH private weth = IWETH(WETH);

    UniswapV3Flashloan private flashloan;

    function setUp() public {
        flashloan = new UniswapV3Flashloan();
    }

    function testFlashloan() public {
        //换weth 并转入flashloan合约用做手续费
        weth.deposit{value: 1e18}();
        weth.transfer(address(flashloan),1e18);

       uint balBefore = weth.balanceOf(address(flashloan));
        //打印日志
        console2.logUint(balBefore);
        flashloan.flashloan(1e18);
    }

    function testFlashloanFail() public {
        weth.deposit{value: 1e18}();
        weth.transfer(address(flashloan),1e17);

        uint amountBorrow = 100 * 1e18;
        //打印日志
        console2.logUint(amountBorrow);

        vm.expectRevert();
        flashloan.flashloan(amountBorrow);
    }
}




