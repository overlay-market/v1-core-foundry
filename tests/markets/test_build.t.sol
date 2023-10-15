// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./conftest.t.sol";
import "./utils.sol";

contract BuildTest is MarketConf, Utils {
    function setUp() public virtual override {
        super.setUp();
    }

    function fuzzTest_build_creates_position(uint256 _notional, uint256 _leverage, bool _isLong) public {
        _notional = bound(_notional, 0.001e18, 80000e18);
        _leverage = bound(_leverage, 1e18, 5e18);
        // NOTE: current position id is zero given isolation fixture
        uint256 expect_pos_id = 0;

        // calculate expected pos info data
        uint256 idx_trade = uint256(RiskParameter.TRADING_FEE_RATE);
        uint256 trading_fee_rate = market.params(idx_trade);
        (uint256 collateral, uint256 notional, uint256 debt, uint256 trade_fee) =
            calculate_position_info(_notional, _leverage, trading_fee_rate);
    }
}
