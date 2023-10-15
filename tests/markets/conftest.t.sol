// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {console2, Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {OverlayV1Token} from "contracts/OverlayV1Token.sol";
import {OverlayV1Market} from "contracts/OverlayV1Market.sol";
import {OverlayV1Factory} from "contracts/OverlayV1Factory.sol";
import {OverlayV1UniswapV3Factory} from "contracts/feeds/uniswapv3/OverlayV1UniswapV3Factory.sol";
import {OverlayV1FeedFactoryMock} from "contracts/mocks/OverlayV1FeedFactoryMock.sol";
import {OverlayV1FeedMock} from "contracts/mocks/OverlayV1FeedMock.sol";
import {OverlayV1Deployer} from "contracts/OverlayV1Deployer.sol";
import {OverlayV1UniswapV3Feed} from "contracts/feeds/uniswapv3/OverlayV1UniswapV3Feed.sol";

contract MarketConf is Test {
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    // to be used as example ovl
    address constant UNI = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address constant UNI_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    ERC20 constant WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IUniswapV3Pool constant POOL_DAI_WETH = IUniswapV3Pool(0xC2e9F25Be6257c210d7Adf0D4Cd6E3E881ba25f8);
    // to be used as example ovlweth pool
    IUniswapV3Pool constant POOL_UNI_WETH = IUniswapV3Pool(0x1d42064Fc4Beb5F8aAF85F4617AE8b3b5B8Bd801);

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

    OverlayV1Token ovl;
    OverlayV1FeedMock fake_feed;
    OverlayV1UniswapV3Factory feed_factory;
    OverlayV1UniswapV3Feed feed;
    OverlayV1FeedFactoryMock mock_feed_factory;
    OverlayV1FeedMock mock_feed;
    OverlayV1Factory factory;
    OverlayV1Deployer fake_deployer;
    OverlayV1Market mock_market;
    OverlayV1Market market;

    function setUp() public virtual {
        vm.createSelectFork(vm.envString("MAINNET_RPC"), 18_330_516);

        vm.label(DAI, "DAI");
        vm.label(address(WETH), "WETH");
        vm.label(UNI, "UNI");
        vm.label(UNI_FACTORY, "UNI_FACTORY");
        vm.label(address(POOL_DAI_WETH), "POOL_DAI_WETH");
        vm.label(address(POOL_UNI_WETH), "POOL_UNI_WETH");

        vm.startPrank(gov);

        uint256 SUPPLY = 8000000;

        ovl = new OverlayV1Token();

        // mint the token then renounce minter role
        ovl.grantRole(MINTER_ROLE, gov);
        ovl.mint(gov, SUPPLY * 10 ** ovl.decimals());
        ovl.renounceRole(MINTER_ROLE, gov);
        ovl.transfer(alice, (SUPPLY / 2) * 10 ** ovl.decimals());
        ovl.transfer(bob, (SUPPLY / 2) * 10 ** ovl.decimals());

        fake_feed = new OverlayV1FeedMock(600, 1800, 1e18, 2000000e18);
        // TODO: change params to (600, 3600, 300, 14)
        feed_factory = new OverlayV1UniswapV3Factory(UNI, UNI_FACTORY, 600, 1800, 240, 15);

        vm.stopPrank();

        // TODO: params for different OverlayV1Feed types ... (to test BalancerV2 and UniswapV3 in same test run)
        feed = OverlayV1UniswapV3Feed(
            feed_factory.deployFeed(
                address(WETH),
                DAI,
                POOL_DAI_WETH.fee(),
                uint128(1 * 10 ** WETH.decimals()),
                address(WETH),
                UNI,
                POOL_UNI_WETH.fee()
            )
        );

        vm.startPrank(gov);

        mock_feed_factory = new OverlayV1FeedFactoryMock(600, 1800);

        vm.stopPrank();

        // Mock feed to easily change price/reserve for testing of various conditions
        mock_feed = OverlayV1FeedMock(mock_feed_factory.deployFeed(1e18, 2000000e18));

        vm.startPrank(gov);

        // create the market factory
        factory = new OverlayV1Factory(address(ovl), fee_recipient);

        // grant market factory token admin role
        ovl.grantRole(ovl.DEFAULT_ADMIN_ROLE(), address(factory));

        // grant gov the governor role on token to access factory methods
        ovl.grantRole(GOVERNOR_ROLE, gov);

        // grant gov the guardian role on token to access factory methods
        ovl.grantRole(GUARDIAN_ROLE, guardian);

        // add both feed factories
        factory.addFeedFactory(address(feed_factory));
        factory.addFeedFactory(address(mock_feed_factory));

        vm.stopPrank();

        vm.startPrank(fake_factory);

        fake_deployer = new OverlayV1Deployer(address(ovl));

        vm.stopPrank();

        uint256[15] memory risk_params = [
            uint256(122000000000), // k
            500000000000000000, // lmbda
            2500000000000000, // delta
            5000000000000000000, // capPayoff
            800000000000000000000000, // capNotional
            5000000000000000000, // capLeverage
            2592000, // circuitBreakerWindow
            66670000000000000000000, // circuitBreakerMintTarget
            100000000000000000, // maintenanceMargin
            100000000000000000, // maintenanceMarginBurnRate
            50000000000000000, // liquidationFeeRate
            750000000000000, // tradingFeeRate
            100000000000000, // minCollateral
            25000000000000, // priceDriftUpperLimit
            14 // averageBlockTime
        ];

        vm.startPrank(gov);

        mock_market = OverlayV1Market(factory.deployMarket(address(mock_feed_factory), address(mock_feed), risk_params));
        market = OverlayV1Market(factory.deployMarket(address(feed_factory), address(feed), risk_params));

        vm.stopPrank();
    }
}
