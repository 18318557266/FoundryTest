// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Lib.sol";

interface IFlashLoanSimpleReceiver{

    /**
   * @notice 在接收闪电借款资产后执行操作
    * @dev 确保合约能够归还债务 + 额外费用，例如，具有
    *      足够的资金来偿还，并已批准 Pool 提取总金额
    * @param asset 闪电借款资产的地址
    * @param amount 闪电借款资产的数量
    * @param premium 闪电借款资产的费用
    * @param initiator 发起闪电贷款的地址
    * @param params 初始化闪电贷款时传递的字节编码参数
    * @return 如果操作的执行成功则返回 True，否则返回 False
    */
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool);
}

contract AAVE3Flashloan is IFlashLoanSimpleReceiver {
    address private constant AAVE_V3_POOL =
    0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    ILendingPool public aave;

    constructor(){
        aave = ILendingPool(AAVE_V3_POOL);
    }

    function flashloan(uint256 wethAmount) external{
        aave.flashLoanSimple(address(this),WETH,wethAmount,"",0);
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool){
        require(msg.sender == AAVE_V3_POOL,"not authorized");
        require(initiator == address(this),"invalid initiator");

        //+1 为了向上取整
        uint fee = (amount * 5)/10000 + 1;
        uint amountRepay = amount + fee;

        IERC20(WETH).approve(AAVE_V3_POOL,amountRepay);
        return true;
    }
}