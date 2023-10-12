// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {console2, Test} from "forge-std/Test.sol";
import {OverlayV1Token} from "contracts/OverlayV1Token.sol";
import {OverlayV1Market} from "contracts/OverlayV1Market.sol";
import {OverlayV1Factory} from "contracts/OverlayV1Factory.sol";
import {OverlayV1UniswapV3Factory} from "contracts/feeds/uniswapv3/OverlayV1UniswapV3Factory.sol";
import {OverlayV1FeedFactoryMock} from "contracts/mocks/OverlayV1FeedFactoryMock.sol";
import {OverlayV1FeedMock} from "contracts/mocks/OverlayV1FeedMock.sol";
import {OverlayV1Deployer} from "contracts/OverlayV1Deployer.sol";
import {OverlayV1UniswapV3Feed} from "contracts/feeds/uniswapv3/OverlayV1UniswapV3Feed.sol";

contract MarketConf is Test {
    address gov = makeAddr("gov");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address rando = makeAddr("rando");
    address fee_recipient = makeAddr("fee_recipient");
    address fake_factory = makeAddr("fake_factory");
    address guardian = makeAddr("guardian");

    bytes32 constant MINTER_ROLE = keccak256("MINTER");
    bytes32 constant BURNER_ROLE = keccak256("BURNER");
    bytes32 constant GOVERNOR_ROLE = keccak256("GOVERNOR");
    bytes32 constant GUARDIAN_ROLE = keccak256("GUARDIAN");

    uint256 constant SUPPLY = 8000000;

    OverlayV1Token token;

    function setUp() public {
        vm.startPrank(gov);
        token = new OverlayV1Token();
        token.grantRole(MINTER_ROLE, gov);
        token.mint(gov, SUPPLY * 10 * token.decimals());
        token.renounceRole(MINTER_ROLE, gov);

        token.transfer(alice, (SUPPLY / 2) * 10 * token.decimals());
        token.transfer(bob, (SUPPLY / 2) * 10 * token.decimals());

        //def ovl(create_token):
    }
}
