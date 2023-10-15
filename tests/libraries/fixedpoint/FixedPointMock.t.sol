// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {FixedPointMock} from "contracts/mocks/FixedPointMock.sol";

contract FixedPointMockTest is Test {

    /////////////////////
    //// conftest.py ////
    /////////////////////
    
    address gov = makeAddr("gov");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address rando = makeAddr("rando");

    FixedPointMock public fixedPoint;

    function setUp() public {
        vm.prank(alice);
        fixedPoint = new FixedPointMock();
    }

    /////////////////////
    //// test_exp.py ////
    /////////////////////

    // I don't know how to find an alternative in foundry for:
    //  "from math import exp" and from pytest import approx

    /*function testExpUp(uint256 _x) public {
        uint256 min_value = 0;
        uint256 max_value = 40;
        _x = bound(_x, min_value, max_value);

        uint256 x_fixed = _x * 1e18;

        uint256 expect = exp(_x) * 1e18;
        uint256 actual = fixedPoint.expUp(x_fixed);

        assertEq(expect, approx(actual));
        // lesser than or equal to
        assertLe(exprct, actual); // check round up error added

    } */

    function testExpUpWhenPowIsZero() public {
        uint256 x = 0;
        uint256 expect = 1000000000000000000;
        uint256 actual = fixedPoint.expUp(x);
        assertEq(expect, actual);
    }

    function testExpUpRevertsWhenXGreaterThanInt256() public {
        // check reverts when greater than int256 max
        uint256 x = 2**255;
        vm.expectRevert(bytes("FixedPoint: x out of bounds"));
        fixedPoint.expUp(x);


    }

    /*
    function testExpDown() public {
        uint256 min_value = 0;
        uint256 max_value = 40;
        _x = bound(_x, min_value, max_value);
    } */

    function testExpDownWhenPowIsZero() public {
        uint256 x = 0;
        uint256 expect = 1000000000000000000;
        uint256 actual = fixedPoint.expDown(x);
        assertEq(expect, actual);
    }

    function testExpDownRevertsWhenXGreaterThanInt256() public {
        // check reverts when greater than int256 max
        uint256 x = 2**255;
        vm.expectRevert(bytes("FixedPoint: x out of bounds"));
        fixedPoint.expDown(x);
    }

}