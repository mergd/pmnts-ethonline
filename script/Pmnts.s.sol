// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Pmnts} from "src/Pmnts.sol";

contract PmntsDeploy is Script {
    Pmnts public pmnt;

    function setUp() public {}

    function run() public {
        pmnt = new Pmnts();
        console2.log("new pmnts addr", address(pmnt));
    }
}
