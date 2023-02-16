// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.13;

import {WETH} from "./mock/WETH.sol";
import {UniswapV2Factory} from "./core/UniswapV2Factory.sol";
import {UniswapV2Router02} from "./periphery/UniswapV2Router02.sol";

contract UniswapV2Deployer {
    UniswapV2Factory public immutable factory;
    UniswapV2Router02 public immutable router;
    WETH public immutable weth;

    constructor() {
        weth = new WETH();
        factory = new UniswapV2Factory(msg.sender);
        router = new UniswapV2Router02(address(factory), address(weth));
    }
}
