// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./conftest.t.sol";
import "./utils.sol";

contract BuildTest is MarketConf, Utils {
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

    function setUp() public virtual override {
        super.setUp();
    }

    function fuzzTest_build_creates_position(uint256 _notional, uint256 _leverage, bool _isLong) public {
        // NOTE: current position id is zero given isolation fixture
        uint256 expect_pos_id = 0;

        // calculate expected pos info data
        uint256 idx_trade = uint256(RiskParameter.TRADING_FEE_RATE);
        uint256 trading_fee_rate = market.params(idx_trade);
        (uint256 collateral, uint256 notional, uint256 debt, uint256 trade_fee) =
            calculate_position_info(_notional, _leverage, trading_fee_rate);
        console2.log("trading_fee_rate", trading_fee_rate);
    }
}
