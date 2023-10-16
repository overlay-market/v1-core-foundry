// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {FixedCastMock} from "contracts/mocks/FixedCastMock.sol";

contract FixedCastTest is Test {

    /////////////////////
    //// conftest.py ////
    /////////////////////

    address alice = makeAddr("alice");

    FixedCastMock public fixedCast;

    function setUp() public {
        vm.prank(alice);
        fixedCast = new FixedCastMock();
    }

    ///////////////////////
    //// test_views.py ////
    ///////////////////////

    function testToUint256Fixed(uint16 _value) public {
        // convert 4 places to 18 places
        uint256 expect = uint256(_value) * uint256(1e14);
        uint256 actual = fixedCast.toUint256Fixed(_value);
        assertEq(expect, actual);
    }
    
    function testToUint16Fixed(uint256 _value) public {
        _value = bound(_value, 0.000001e18, 6.5535e18);

        uint256 expect = _value / 1e14;
        uint256 actual = fixedCast.toUint16Fixed(_value);
        assertEq(expect, actual);
    }

    function testToUint16Touint256Fixed(uint256 _value) public {
        // convert 18 places to 4 places back to 18 places rounded down
        _value = bound(_value, 0.000001e18, 6.5535e18);
        uint256 expect = (_value / 1e14) * 1e14;
        uint256 actual = fixedCast.toUint256Fixed(fixedCast.toUint16Fixed(_value));
        assertEq(expect, actual);
    }

    function testToUint16FixedRevertsWhenGtMax() public {
        // Should pass for type(uint16).max
        uint256 value = 2**16-1;
        uint256 inputValue = value * 1e14;
        uint256 expect = value;
        uint16 actual = fixedCast.toUint16Fixed(inputValue);
        assertEq(expect, actual);

        // Should fail for type(uint16).max + 1
        value = 2**16;
        inputValue = value * 1e14;
        vm.expectRevert(bytes("OVLV1: FixedCast out of bounds"));
        fixedCast.toUint16Fixed(inputValue);
    }
}

