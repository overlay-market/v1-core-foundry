// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./FixedPointConf.t.sol";

contract ExpTest is FixedPointConf {
    

    function setUp() public virtual override {
        super.setUp();
    }

    /////////////////////
    //// test_exp.py ////
    /////////////////////


    /* function test_exp_up(uint256 _x) public {

        _x = bound(_x, 0, 40);

        uint256 x_fixed = _x * 1e18;

        uint256 expect = uint256(FixedPointMathLib.expWad(int256(_x))); //???????
        uint256 actual = fixedPoint.expUp(x_fixed);
        

        assertApproxEqAbs(expect, actual, //delta );
        // lesser than or equal to
        assertLe(expect, actual); // check round up error added

    } */

    function test_exp_up_when_pow_is_zero() public {
        uint256 x = 0;
        uint256 expect = 1000000000000000000;
        uint256 actual = fixedPoint.expUp(x);
        assertEq(expect, actual);
    }

    function test_exp_up_reverts_when_x_greater_than_int256() public {
        // check reverts when greater than int256 max
        uint256 x = 2**255;
        vm.expectRevert(bytes("FixedPoint: x out of bounds"));
        fixedPoint.expUp(x);
    }
   
    /*
    function testExpDown(_x) public {
        _x = bound(_x, 0, 40);
    } */

    function test_exp_down_when_pow_is_zero() public {
        uint256 x = 0;
        uint256 expect = 1000000000000000000;
        uint256 actual = fixedPoint.expDown(x);
        assertEq(expect, actual);
    }

    function test_exp_down_reverts_when_x_greater_than_int256() public {
        // check reverts when greater than int256 max
        uint256 x = 2**255;
        vm.expectRevert(bytes("FixedPoint: x out of bounds"));
        fixedPoint.expDown(x);
    }
}