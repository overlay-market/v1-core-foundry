// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract Utils {
    function calculate_position_info(uint256 notional, uint256 leverage, uint256 trading_fee_rate)
        public
        pure
        returns (uint256, uint256, uint256, uint256)
    {
        uint256 collateral = notional / leverage;
        uint256 trade_fee = (notional * trading_fee_rate) / 1e18;
        uint256 debt = notional - collateral;

        return (collateral, notional, debt, trade_fee);
    }
}
