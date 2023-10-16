// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./conftest.t.sol";
import "./utils.sol";

contract BuildTest is MarketConf, Utils {
    using FixedPointMathLib for uint256;

    function setUp() public virtual override {
        super.setUp();
    }

    function test_build_creates_position(uint256 _notional, uint256 _leverage, bool _isLong) public {
        _notional = bound(_notional, 0.001e18, 80000e18);
        _leverage = bound(_leverage, 1e18, 5e18);

        // calculate expected pos info data
        uint256 trading_fee_rate = marketParams(RiskParameter.TRADING_FEE_RATE);
        PositionInfo memory positionInfo = calculate_position_info(_notional, _leverage, trading_fee_rate);

        // NOTE: slippage tests in test_slippage.py
        // NOTE: setting to min/max here, so never reverts with slippage>max

        uint256 price_limit = _isLong ? type(uint256).max : 0;

        // approve market for spending then build
        vm.startPrank(alice);
        ovl.approve(address(market), positionInfo.collateral + positionInfo.trade_fee);
        uint256 actual_pos_id = market.build(positionInfo.collateral, _leverage, _isLong, price_limit);
        vm.stopPrank();

        // check position id, current position id is zero given isolation fixture
        assertEq(actual_pos_id, 0);

        // calculate oi and expected entry price
        // NOTE: ask(), bid() tested in test_price.py

        Oracle.Data memory data = feed.latest();
        uint256 mid_price = mid_from_feed(data);
        uint256 oi = _notional.divWadUp(mid_price);

        uint256 cap_notional = market.capNotionalAdjustedForBounds(data, marketParams(RiskParameter.CAP_NOTIONAL));
        uint256 cap_oi = cap_notional.divWadUp(mid_price);

        uint256 volume = oi.divWadUp(cap_oi);
        uint256 price = price(_isLong, data, volume);

        (
            uint96 actual_notional_initial,
            uint96 actual_debt,
            int24 actual_mid_tick,
            int24 actual_entry_tick,
            bool actual_is_long,
            bool actual_liquidated,
            uint240 actual_oi_shares,
            uint16 actual_fraction_remaining
        ) = market.positions(get_position_key(alice, actual_pos_id));

        // MIGRATION STACK TOO DEEP
    }

    //Internal functions to avoid error: Stack too deep.

    function price(bool _isLong, Oracle.Data memory _data, uint256 _volume) internal view returns (uint256) {
        return _isLong ? market.ask(_data, _volume) : market.bid(_data, _volume);
    }

    function marketParams(RiskParameter _param) internal view returns (uint256) {
        return market.params(uint256(_param));
    }
}
