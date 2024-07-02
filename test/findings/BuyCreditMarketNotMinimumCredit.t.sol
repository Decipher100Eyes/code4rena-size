// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {BaseTest} from "@test/BaseTest.sol";

import {RESERVED_ID} from "@src/libraries/LoanLibrary.sol";
import {BuyCreditMarketParams} from "@src/libraries/actions/BuyCreditMarket.sol";

contract BuyCreditMarketNotMinimumCreditTest is BaseTest {
    function test_BuyCreditMarket_NotMinimumCredit_validation() public {
        _deposit(candy, usdc, 100e6);
        _deposit(james, weth, 100e18);
        _sellCreditLimit(james, 0.03e18, 365 days);

        uint256 deadline = block.timestamp;
        uint256 tenor = 365 days;
        bool exactAmountIn = true;

        vm.startPrank(candy);
        uint256 minCashAmountIn = 4854369; // the future value for the limit order and the tenor is 5000000, the minimum credit.

        size.buyCreditMarket(
            BuyCreditMarketParams({
                borrower: james,
                creditPositionId: RESERVED_ID,
                amount: minCashAmountIn,
                tenor: tenor,
                deadline: deadline,
                minAPR: 0,
                exactAmountIn: exactAmountIn
            })
        );
        vm.stopPrank();
    }
}