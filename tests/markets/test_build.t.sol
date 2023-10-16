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
        uint256 oi = _notional.divWad(mid_price(data));

        uint256 cap_oi = cap_notional(data).divWad(mid_price(data));

        uint256 volume = oi.divWad(cap_oi);
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
        assertApproxEqAbs(realPosition.notionalInitial, _notional, 10);
        assertApproxEqAbs(realPosition.oiShares, oi, 10);
        assertApproxEqAbs(realPosition.debtInitial, positionInfo.debt, 10);
        assertApproxEqAbs(realPosition.fractionRemaining, 1e4, 10);
    }

    function test_build_adds_oi(uint256 _notional, uint256 _leverage, bool _isLong) public {
        _notional = bound(_notional, 0.001e18, 80000e18);
        _leverage = bound(_leverage, 1e18, 5e18);

        // calculate expected pos info data
        PositionInfo memory positionInfo = calculate_position_info(_notional, _leverage, trading_fee_rate());

        // priors actual values
        vm.startPrank(alice);
        market.update();

        (uint256 expect_oi, uint256 expect_oi_shares) = marketOI(_isLong);

        // approve market for spending then build
        ovl.approve(address(market), positionInfo.collateral + positionInfo.trade_fee);
        uint256 actual_pos_id = market.build(positionInfo.collateral, _leverage, _isLong, price_limit(_isLong));
        vm.stopPrank();

        // calculate oi
        Oracle.Data memory data = feed.latest();
        uint256 oi = _notional.divWad(mid_price(data));
        uint256 oi_shares = oi;

        // calculate expected oi info data
        expect_oi += oi;
        expect_oi_shares += oi_shares;

        //compare with actual aggregate oi values
        (uint256 actual_oi, uint256 actual_oi_shares) = marketOI(_isLong);

        // NOTE: rel tol of 1e-4 given tick has precision to 1bps
        assertApproxEqAbs(actual_oi, expect_oi, 2);
        assertApproxEqAbs(actual_oi_shares, expect_oi_shares, 2);

        // check oi shares given to position matches oi shares added to aggregates
        Position.Info memory realPosition = expected_position(alice, actual_pos_id);
        // only one position so aggregate should equal individual pos shares
        assertEq(realPosition.oiShares, oi_shares);

        // pass some time for funding to have oi deviate from oiShares
        skip(604800);
        vm.startPrank(alice);
        market.update();
        vm.stopPrank();

        // cache prior oi and oiShares aggregate values after update
        (expect_oi, expect_oi_shares) = marketOI(_isLong);

        // approve market for spending then build again
        vm.startPrank(alice);
        ovl.approve(address(market), positionInfo.collateral + positionInfo.trade_fee);
        market.build(positionInfo.collateral, _leverage, _isLong, price_limit(_isLong));

        // recalculate oi
        data = feed.latest();
        oi = _notional.divWad(mid_price(data));
        oi_shares = oi.mulWad(expect_oi.divWad(expect_oi));

        // calculate expected oi info data on second build
        expect_oi += oi;
        expect_oi_shares += oi_shares;

        // compare with actual aggregate oi values
        (actual_oi, actual_oi_shares) = marketOI(_isLong);

        // NOTE: rel tol of 1e-4 given tick has precision to 1bps
        assertApproxEqAbs(actual_oi, expect_oi, 2);
        assertApproxEqAbs(actual_oi_shares, expect_oi_shares, 2);
    }

    //Internal functions to avoid error "Stack too deep".

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

    function marketOI(bool _isLong) internal view returns (uint256, uint256) {
        uint256 oi = _isLong ? market.oiLong() : market.oiShort();
        uint256 oi_shares = _isLong ? market.oiLongShares() : market.oiShortShares();
        return (oi, oi_shares);
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
}
