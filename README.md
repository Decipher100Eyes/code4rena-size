## Impact

SellCreditMarket wastes gas and emits redundant events.

## Root cause and summary

In SellCreditMarket, currently it creates a dummy position with createDebtAndCreditPositions if creditPositionId is RESERVE_ID and executes createCreditPostion right after that.
However, this process is not necessary if the design of the code follows the way which BuyCreditMarket uses.

## Proof of Concept

        if (params.creditPositionId == RESERVED_ID) {
            state.createDebtAndCreditPositions({
                lender: params.lender,
                borrower: msg.sender,
                futureValue: creditAmountIn,
                dueDate: block.timestamp + tenor
            });
        } else {
            state.createCreditPosition({
                exitCreditPositionId: params.creditPositionId,
                lender: params.lender,
                credit: creditAmountIn
            });
        }

This code passes the all the tests that size protocol wants and saves the gas.
In every test using "SellCreditMarket", the new code spends less gas. The new code also does not create unnecessary events.

https://github.com/Decipher100Eyes/code4rena-size/commit/d4ae67f590adb9c33ebbc07e9f1ab0bb7c2967a0

## Tools Useda

foundry
