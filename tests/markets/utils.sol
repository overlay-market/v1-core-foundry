// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {FixedPointMathLib} from "solady/src/utils/FixedPointMathLib.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Oracle} from "contracts/libraries/Oracle.sol";
import {Position} from "contracts/libraries/Position.sol";

contract Utils {
    using FixedPointMathLib for uint256;

    struct PositionInfo {
        uint256 collateral;
        uint256 debt;
        uint256 trade_fee;
    }

    struct OIValues {
        uint256 oi;
        uint256 oi_shares;
    }

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
        internal
        pure
        returns (PositionInfo memory)
    {
        /*
        Returns position attributes
        */
        // MIGRATION: Verify that return values are right.
        uint256 collateral = notional.divWad(leverage);
        uint256 trade_fee = notional * trading_fee_rate;
        uint256 debt = notional - collateral;

        return PositionInfo(collateral, debt, trade_fee);
    }

    function mid_from_feed(Oracle.Data memory data) internal pure returns (uint256) {
        /*
        Returns mid price from feed
        */
        // MIGRATION: Verify that return values are right.
        uint256 price_micro = data.priceOverMicroWindow;
        uint256 price_macro = data.priceOverMacroWindow;
        uint256 ask = Math.max(price_micro, price_macro);
        uint256 bid = Math.min(price_micro, price_macro);
        return (ask + bid) / 2;
    }

    function get_position_key(address _owner, uint256 _pos_id) internal pure returns (bytes32) {
        /*
        Returns the position key to retrieve an individual position
        from positions mapping
        */
        // MIGRATION: Verify that return values are right.
        return keccak256(abi.encodePacked(_owner, _pos_id));
    }
}
