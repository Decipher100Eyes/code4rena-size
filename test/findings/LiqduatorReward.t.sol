// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LiquidateParams} from "@src/libraries/actions/Liquidate.sol";
import {BaseTest} from "@test/BaseTest.sol";
import {Vars} from "@test/BaseTest.sol";

import {LoanStatus, RESERVED_ID} from "@src/libraries/LoanLibrary.sol";
import {Math} from "@src/libraries/Math.sol";
import {PERCENT} from "@src/libraries/Math.sol";
import {YieldCurveHelper} from "@test/helpers/libraries/YieldCurveHelper.sol";

contract LiquidatorRewardCapTest is BaseTest {
    function test_Liquidate_liquidator_profit() public {
        _setPrice(1e18);

        _deposit(alice, weth, 100e18);
        _deposit(alice, usdc, 100e6);
        _deposit(bob, weth, 100e18);
        _deposit(bob, usdc, 100e6);
        _deposit(liquidator, weth, 100e18);
        _deposit(liquidator, usdc, 100e6);

        _buyCreditLimit(alice, block.timestamp + 365 days, YieldCurveHelper.pointCurve(365 days, 0.03e18));
        uint256 debtPositionId = _sellCreditMarket(bob, alice, RESERVED_ID, 15e6, 365 days, false);
        uint256 futureValue = size.getDebtPosition(debtPositionId).futureValue;

        // collateral price dropped
        _setPrice(0.16e18);

        assertTrue(size.isDebtPositionLiquidatable(debtPositionId), "Not liquidatable");
        // assert bob's crLiquidation < crLiquidation
        assertTrue(size.isUserUnderwater(bob), "Not underwater");

        Vars memory _before = _state();
        uint256 assignedCollateral = _before.bob.collateralTokenBalance;
        uint256 debtInCollateralToken = size.debtTokenAmountToCollateralTokenAmount(futureValue);
        // assert profitable liquidation
        assertGt(assignedCollateral, debtInCollateralToken, "Not profitable liquidation");

        // assert calculated liquidator reward is below cap
        // so liquidatorReward must be calculated liquidator reward(collateralTokenBalance - debtInCollateralToken)
        assertGt(
            size.debtTokenAmountToCollateralTokenAmount(
                Math.mulDivUp(futureValue, size.feeConfig().liquidationRewardPercent, PERCENT)
            ),
            _state().bob.collateralTokenBalance - debtInCollateralToken,
            "calculated liquidator reward is above cap"
        );
        uint256 liquidatorReward = _state().bob.collateralTokenBalance - debtInCollateralToken;
        uint256 liquidatorProfitCollateralToken = debtInCollateralToken + liquidatorReward;

        _liquidate(liquidator, debtPositionId);

        Vars memory _after = _state();
        assertEq(
            _after.liquidator.collateralTokenBalance,
            _before.liquidator.collateralTokenBalance + liquidatorProfitCollateralToken,
            "Wrong profit calculation"
        );
    }
}
