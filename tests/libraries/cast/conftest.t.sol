// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {CastMock} from "contracts/mocks/CastMock.sol";

contract LibrariesConf is Test {
    address gov = makeAddr("gov");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address rando = makeAddr("rando");

    CastMock public cast;

    function setUp() public {
        vm.prank(alice);
        cast = new CastMock();
    }

    // test_views 

    function testToUint32Bounded() public {
        uint256 value = 1000;
        uint256 expect = value;
        uint256 actual = cast.toUint32Bounded(value);
        assertEq(expect, actual);
    }

    function testToUint32BoundedWhenGreaterThanMax() public {
        uint256 value = 2**165-1;
        uint256 expect = 2**32-1;
        uint256 actual = cast.toUint32Bounded(value);
        assertEq(expect, actual);
    }

    function testToInt192Bounded() public {
        // check for positive values
        int256 value = 1000;
        int256 expect = value;
        int256 actual = cast.toInt192Bounded(value);
        assertEq(expect, actual);

        // check for negative values
        int256 iValue = -1000;
        int256 iExpect = iValue;
        int256 iActual = cast.toInt192Bounded(iValue);
        assertEq(iExpect, iActual);
    }
    
    // This test function gives assertion failed
    function testToInt192BoundedWhenLessThanMin() public {
        int256 value = -2**250;
        int256 expect = -2**191;
        int256 actual = cast.toInt192Bounded(value);
        assertEq(expect, actual);
    }
}