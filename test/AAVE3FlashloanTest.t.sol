pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {IWETH} from "../src/flashloan/Lib.sol";
import {AAVE3Flashloan} from "../src/flashloan/AAVE3Flashloan.sol";

address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

contract AAVE3FlashloanTest is Test{
    IWETH private weth = IWETH(WETH);
    AAVE3Flashloan private aave;

    function setUp() public {
        aave = new AAVE3Flashloan();
    }

    function testFlashloan() public {
        weth.deposit{value : 1e18}();
        weth.transfer(address(aave),1e18);
        uint amountBorrow = 100 * 1e18;
        aave.flashloan(amountBorrow);
    }
}