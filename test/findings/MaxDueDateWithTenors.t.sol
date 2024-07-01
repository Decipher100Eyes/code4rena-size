// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {BaseTest} from "@test/BaseTest.sol";

import {Errors} from "@src/libraries/Errors.sol";
import {RESERVED_ID} from "@src/libraries/LoanLibrary.sol";

import {YieldCurve} from "@src/libraries/YieldCurveLibrary.sol";

import {BuyCreditLimitParams} from "@src/libraries/actions/BuyCreditLimit.sol";
import {SellCreditMarketParams} from "@src/libraries/actions/SellCreditMarket.sol";

contract BuyCreditLimitTest is BaseTest {
    function test_BuyCreditLimit() public {
        _setPrice(1e18);
        _deposit(alice, usdc, 1_000e6);
        _deposit(bob, weth, 300e18);

        uint256 maxDueDate = block.timestamp + 30 days;
        uint256[] memory marketRateMultipliers = new uint256[](2);
        uint256[] memory tenors = new uint256[](2);
        tenors[0] = 40 days;
        tenors[1] = 90 days;
        int256[] memory aprs = new int256[](2);
        aprs[0] = 0.12e18;
        aprs[1] = 0.15e18;

        vm.prank(alice);
        size.buyCreditLimit(
            BuyCreditLimitParams({
                maxDueDate: maxDueDate,
                curveRelativeTime: YieldCurve({tenors: tenors, marketRateMultipliers: marketRateMultipliers, aprs: aprs})
            })
        );

        uint256 tenor = 40 days;
        uint256 apr = size.getLoanOfferAPR(alice, tenor);
        size.sellCreditMarket(
            SellCreditMarketParams({
                lender: alice,
                creditPositionId: RESERVED_ID,
                amount: 100e6,
                tenor: tenor,
                deadline: block.timestamp,
                maxAPR: apr,
                exactAmountIn: false
            })
        );
    }

    function testFuzz_BuyCreditLimit(uint256 tenor) public {
        _setPrice(1e18);
        _deposit(alice, usdc, 1_000e6);
        _deposit(bob, weth, 300e18);

        uint256 maxDueDate = block.timestamp + 30 days;
        uint256[] memory marketRateMultipliers = new uint256[](2);
        uint256[] memory tenors = new uint256[](2);
        tenors[0] = 40 days;
        tenors[1] = 90 days;
        int256[] memory aprs = new int256[](2);
        aprs[0] = 0.12e18;
        aprs[1] = 0.15e18;

        vm.prank(alice);
        size.buyCreditLimit(
            BuyCreditLimitParams({
                maxDueDate: maxDueDate,
                curveRelativeTime: YieldCurve({tenors: tenors, marketRateMultipliers: marketRateMultipliers, aprs: aprs})
            })
        );

        tenor = bound(tenor, tenors[0], tenors[1]);
        uint256 apr = size.getLoanOfferAPR(alice, tenor);

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.DUE_DATE_GREATER_THAN_MAX_DUE_DATE.selector, block.timestamp + tenor, maxDueDate
            )
        );

        size.sellCreditMarket(
            SellCreditMarketParams({
                lender: alice,
                creditPositionId: RESERVED_ID,
                amount: 100e6,
                tenor: tenor,
                deadline: block.timestamp,
                maxAPR: apr,
                exactAmountIn: false
            })
        );
    }
}
