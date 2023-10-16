// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./conftest.t.sol";
import "./utils.sol";

contract BuildTest is MarketConf, Utils {
    using FixedPointMathLib for uint256;

    event Build(address indexed sender, uint256 positionId, uint256 oi, uint256 debt, bool isLong, uint256 price);

    function setUp() public virtual override {
        super.setUp();
    }

    function test_build_creates_position(uint256 _notional, uint256 _leverage, bool _isLong) public {
        _notional = bound(_notional, 0.001e18, 80000e18);
        _leverage = bound(_leverage, 1e18, 5e18);

        // calculate expected pos info data
        PositionInfo memory positionInfo = calculate_position_info(_notional, _leverage, trading_fee_rate());

        // calculate oi and expected entry price
        // NOTE: ask(), bid() tested in test_price.py

        Oracle.Data memory data = feed.latest();
        uint256 oi = _notional.divWadUp(mid_price(data));

        uint256 cap_oi = cap_notional(data).divWadUp(mid_price(data));

        uint256 volume = oi.divWadUp(cap_oi);
        uint256 price = get_price(_isLong, data, volume);

        // approve market for spending then build
        vm.startPrank(alice);
        ovl.approve(address(market), positionInfo.collateral + positionInfo.trade_fee);
        vm.expectEmit(true, false, false, false);
        // chek build events
        emit Build(alice, 0, oi, positionInfo.debt, _isLong, price);
        uint256 actual_pos_id = market.build(positionInfo.collateral, _leverage, _isLong, price_limit(_isLong));
        vm.stopPrank();

        // check position id, current position id is zero given isolation fixture
        assertEq(actual_pos_id, 0);

        Position.Info memory realPosition = expected_position(alice, actual_pos_id);

        // check position attributes
        assertEq(realPosition.isLong, _isLong);
        assertEq(realPosition.liquidated, false);
        assertApprox(realPosition.notionalInitial, _notional, 10);
        assertApprox(realPosition.oiShares, oi, 10);
        assertApprox(realPosition.debtInitial, positionInfo.debt, 10);
        assertApprox(realPosition.fractionRemaining, 1e4, 10);
    }

    //Internal functions to avoid error: Stack too deep.

    function trading_fee_rate() internal view returns (uint256) {
        return marketParams(RiskParameter.TRADING_FEE_RATE);
    }

    function get_price(bool _isLong, Oracle.Data memory _data, uint256 _volume) internal view returns (uint256) {
        return _isLong ? market.ask(_data, _volume) : market.bid(_data, _volume);
    }

    function mid_price(Oracle.Data memory _data) internal pure returns (uint256) {
        return mid_from_feed(_data);
    }

    function price_limit(bool _isLong) internal pure returns (uint256) {
        // NOTE: slippage tests in test_slippage.py
        // NOTE: setting to min/max here, so never reverts with slippage>max
        return _isLong ? type(uint256).max : 0;
    }

    function marketParams(RiskParameter _idx) internal view returns (uint256) {
        return market.params(uint256(_idx));
    }

    function cap_notional(Oracle.Data memory _data) internal view returns (uint256) {
        return market.capNotionalAdjustedForBounds(_data, marketParams(RiskParameter.CAP_NOTIONAL));
    }

    function expected_position(address _user, uint256 _pos_id) internal view returns (Position.Info memory) {
        (
            uint96 actual_notional_initial,
            uint96 actual_debt,
            int24 actual_mid_tick,
            int24 actual_entry_tick,
            bool actual_is_long,
            bool actual_liquidated,
            uint240 actual_oi_shares,
            uint16 actual_fraction_remaining
        ) = market.positions(get_position_key(_user, _pos_id));

        return Position.Info(
            actual_notional_initial,
            actual_debt,
            actual_mid_tick,
            actual_entry_tick,
            actual_is_long,
            actual_liquidated,
            actual_oi_shares,
            actual_fraction_remaining
        );
    }

    function assertApprox(uint256 actual, uint256 expected, uint256 precision) internal {
        if (actual > expected) {
            assertLe(actual - expected, precision);
        } else {
            assertLe(expected - actual, precision);
        }
    }
}
