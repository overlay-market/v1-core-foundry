// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./conftest.t.sol";
import "./utils.sol";

contract BuildTest is MarketConf, Utils {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_build_creates_position(uint256 _notional, uint256 _leverage, bool _isLong) public {
        _notional = bound(_notional, 0.001e18, 80000e18);
        _leverage = bound(_leverage, 1e18, 5e18);
        // NOTE: current position id is zero given isolation fixture
        uint256 expect_pos_id;

        // calculate expected pos info data
        uint256 idx_trade = uint256(RiskParameter.TRADING_FEE_RATE);
        uint256 trading_fee_rate = market.params(idx_trade);
        (uint256 collateral, uint256 notional, uint256 debt, uint256 trade_fee) =
            calculate_position_info(_notional, _leverage, trading_fee_rate);

        // NOTE: slippage tests in test_slippage.py
        // NOTE: setting to min/max here, so never reverts with slippage>max

        uint256 price_limit = _isLong ? type(uint256).max : 0;

        // approve collateral amount: collateral + trade fee
        uint256 approve_collateral = collateral + trade_fee;

        // approve market for spending then build
        vm.startPrank(alice);
        ovl.approve(address(market), approve_collateral);
        uint256 actual_pos_id = market.build(collateral, _leverage, _isLong, price_limit);
        vm.stopPrank();

        // check position id
        assertEq(actual_pos_id, expect_pos_id);
    }
}
