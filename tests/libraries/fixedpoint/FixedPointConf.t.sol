// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {FixedPointMock} from "contracts/mocks/FixedPointMock.sol";
import {FixedPointMathLib} from "solady/src/utils/FixedPointMathLib.sol";

contract FixedPointConf is Test {

    /////////////////////
    //// conftest.py ////
    /////////////////////
    
    address gov = makeAddr("gov");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address rando = makeAddr("rando");

    FixedPointMock public fixedPoint;

    using FixedPointMathLib for uint256;

    function setUp() public virtual {
        vm.prank(alice);
        fixedPoint = new FixedPointMock();
    }
}