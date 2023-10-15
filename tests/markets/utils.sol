// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract Utils {
    enum RiskParameter {
        K, // 0
        LMBDA, // 1
        DELTA, // 2
        CAP_PAYOFF, // 3
        CAP_NOTIONAL, // 4
        CAP_LEVERAGE, // 5
        CIRCUIT_BREAKER_WINDOW, // 6
        CIRCUIT_BREAKER_MINT_TARGET, // 7
        MAINTENANCE_MARGIN_FRACTION, // 8
        MAINTENANCE_MARGIN_BURN_RATE, // 9
        LIQUIDATION_FEE_RATE, // 10
        TRADING_FEE_RATE, // 11
        MIN_COLLATERAL, // 12
        PRICE_DRIFT_UPPER_LIMIT, // 13
        AVERAGE_BLOCK_TIME // 14
    }

    function calculate_position_info(uint256 notional, uint256 leverage, uint256 trading_fee_rate)
        public
        pure
        returns (uint256, uint256, uint256, uint256)
    {
        /*
        Returns position attributes
        */
        // MIGRATION: Verify that return values are right.
        uint256 collateral = notional / leverage;
        uint256 trade_fee = (notional * trading_fee_rate) / 1e18;
        uint256 debt = notional - collateral;

        return (collateral, notional, debt, trade_fee);
    }
}
