// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

import {UniswapV2Library} from "src/libraries/UniswapV2Library.sol";
import {UniswapV2Deployer} from "src/UniswapV2Deployer.sol";
import {UniswapV2Factory} from "src/core/UniswapV2Factory.sol";
import {UniswapV2Router02} from "src/periphery/UniswapV2Router02.sol";
import {WETH} from "src/mock/WETH.sol";

contract USDT is ERC20 {
    constructor() ERC20("USDT", "USDT") {
        _mint(msg.sender, 1e12);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}

contract Uniswap is Test, Script {
    UniswapV2Factory public factory;
    UniswapV2Router02 public router;
    USDT public usdt;
    WETH public weth;

    // solhint-disable-next-line no-empty-blocks
    function setUp() public {
        UniswapV2Deployer deployer = new UniswapV2Deployer();
        factory = UniswapV2Factory(deployer.factory());
        router = UniswapV2Router02(deployer.router());
        weth = WETH(deployer.weth());
        usdt = new USDT();
    }

    function testPairFor() public {
        factory.createPair(address(usdt), address(weth));
        address pair = factory.getPair(address(usdt), address(weth));
        address expPair = UniswapV2Library.pairFor(address(factory), address(usdt), address(weth));
        assertTrue(pair == expPair);
    }

    function testCreatePair() public {
        factory.createPair(address(usdt), address(weth));
        address pair = factory.getPair(address(usdt), address(weth));
        assertTrue(pair != address(0));
    }

    function testAddLiquidityETH() public {
        usdt.approve(address(router), type(uint256).max);
        usdt.mint(address(this), 1e12);
        vm.prank(address(this));
        router.addLiquidityETH{value: 1e18}(address(usdt), 1e12, 1e12, 1e18, address(this), block.timestamp);
        (uint256 res0, uint256 res1) = UniswapV2Library.getReserves(address(factory), address(usdt), address(weth));
        assertTrue(res0 == 1e12);
        assertTrue(res1 == 1e18);
    }
}
