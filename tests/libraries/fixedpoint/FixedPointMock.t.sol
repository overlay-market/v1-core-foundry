// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {FixedPointMock} from "contracts/mocks/FixedPointMock.sol";
import {FixedPointMathLib} from "solady/src/utils/FixedPointMathLib.sol";

contract FixedPointMockTest is Test {

    /////////////////////
    //// conftest.py ////
    /////////////////////
    
    address gov = makeAddr("gov");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address rando = makeAddr("rando");

    FixedPointMock public fixedPoint;

    using FixedPointMathLib for uint256;

    function setUp() public {
        vm.prank(alice);
        fixedPoint = new FixedPointMock();
    }

    /////////////////////
    //// test_exp.py ////
    /////////////////////

    // I don't know how to find an alternative in foundry for:
    //  "from math import exp" and from pytest import approx

    /* function testExpUp(uint256 _x) public {

        _x = bound(_x, 0, 40);

        uint256 x_fixed = _x * 1e18;

        uint256 expect = fixedPoint.expWad(_x); //???????
        uint256 actual = fixedPoint.expUp(x_fixed);

        //assertEq(expect, approx(actual));
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