// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./FixedPointConf.t.sol";

contract LogTest is FixedPointConf {

    function setUp() public virtual override {
        super.setUp();
    }


    // test_log_up ?



    function test_log_up_reverts_a_is_zero() public {
        uint256 a = 0;
        uint256 b = 1;

        vm.expectRevert(bytes("FixedPoint: a out of bounds"));
        fixedPoint.logUp(a, b);
    }

    function test_log_up_reverts_a_gt_max() public {
        uint256 a = 2**255;
        uint256 b = 1;

        vm.expectRevert(bytes("FixedPoint: a out of bounds"));
        fixedPoint.logUp(a, b);
    }

    function test_log_up_reverts_b_is_zero() public {
        uint256 a = 1;
        uint256 b = 0;

        vm.expectRevert(bytes("FixedPoint: b out of bounds"));
        fixedPoint.logUp(a, b);
    }


}