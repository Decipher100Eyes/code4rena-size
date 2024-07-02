// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {BaseTest} from "@test/BaseTest.sol";

import {RESERVED_ID} from "@src/libraries/LoanLibrary.sol";
import {SellCreditMarketParams} from "@src/libraries/actions/SellCreditMarket.sol";

contract SellCreditMarketNotMinimumCreditTest is BaseTest {
    function test_SellCreditMarket_NotMinimumCredit_validation() public {
        _deposit(candy, weth, 100e18);
        _deposit(james, usdc, 100e6);
        _buyCreditLimit(
            james, block.timestamp + 365 days, [int256(0.03e18), int256(0.03e18)], [uint256(10 days), uint256(365 days)]
        );

        uint256 deadline = block.timestamp;
        uint256 tenor = 365 days;
        bool exactAmountIn = false;

        vm.startPrank(candy);
        uint256 ratePerTenor = size.getLoanOfferAPR(james, tenor);
        uint256 minCashAmountIn = 4830097; // the future value for the limit order and the tenor is 5000000, the minimum credit.

        size.sellCreditMarket(
            SellCreditMarketParams({
                lender: james,
                creditPositionId: RESERVED_ID,
                amount: minCashAmountIn,
                tenor: 365 days,
                deadline: deadline,
                maxAPR: type(uint256).max,
                exactAmountIn: exactAmountIn
            })
        );
        vm.stopPrank();
    }
}