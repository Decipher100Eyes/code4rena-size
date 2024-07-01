# Audit report: Suggestions for optimizing gas usage in LiquidateWithReplacement.sol

## Impact and Summary

In Solidity, when a variable objet is assigned through memory copy, there is a difference in gas usage between a structure and a single variable. Therefore, in order to optimize gas usage, it is more efficient to memory copy only necessary variables rather than memory copy the entire structure.
To reduce gas usage in size project, we revised the `executeLiquidate()` function and run a test code file(`LiquidateWithReplacement.t.sol`). As a result, gas usage was reduced in 4 of the 5 unit tests.

## Root cause

In the `executeLiquidateWithReplacement()` function of `LiquidateWithReplacement.sol file`, the `debtPositionCopy` variable, which copies `debtPosition` (struct object) to memory, is needed to restore the `debtPosition.futureValue` (uint256) which is updated by the `executeLiquidate()` function.

At this time, rather than copying the entire `debtPosition` structure object, gas usage can be reduced by copying only the actually needed value, `debtPosition.futureValue`.

## Proof of Concept

You can compare code changes: https://github.com/Decipher100Eyes/code4arena-size/commit/4d084263ddc65c604675623b223dfad814d8de5e

The log below shows the results of comparing gas usage using the `LiquidateWithReplacement.t.sol` file. “consumed” refers to the gas consumption of our proposed code, and “expected” refers to the gas consumption of the existing code.

- **"LiquidateWithReplacementTest::test_LiquidateWithReplacement_liquidateWithReplacement_cannot_leave_new_borrower_liquidatable()": consumed "(gas: 2209750)" gas, expected "(gas: 2210048)" gas**
- **"LiquidateWithReplacementTest::test_LiquidateWithReplacement_liquidateWithReplacement_experiment()": consumed "(gas: 2600537)" gas, expected "(gas: 2600835)" gas**
- **"LiquidateWithReplacementTest::test_LiquidateWithReplacement_liquidateWithReplacement_updates_new_borrower_borrowOffer_different_rate()": consumed "(gas: 2990403)" gas, expected "(gas: 2990700)" gas**
- **"LiquidateWithReplacementTest::test_LiquidateWithReplacement_liquidateWithReplacement_updates_new_borrower_borrowOffer_same_rate()": consumed "(gas: 3003855)" gas, expected "(gas: 3004152)"**

## Tools Used

To know the gas useage, we utilize Foundary framework (https://github.com/foundry-rs/foundry).

## Recommended Mitigation Steps

We recommend revising some codes in the file `LiquidateWithReplacement.sol` to use `futureValueCopy` instead of memory copying `debtPositionCopy`.
