// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "src/WrapperMinter.sol";

contract PmntsDeploy is Script {
    WrapperMinter public wrapper;
    ERC20 public cUSDCGoerli = ERC20(0x3EE77595A8459e93C2888b13aDB354017B198188);

    ERC20 public apeGoerli = ERC20(0x328507DC29C95c170B56a1b3A758eB7a9E73455c);

    function setUp() public {}

    function run() public {
        uint256 deployerPK = vm.envUint("DEPLOYER_PK");

        vm.startBroadcast(deployerPK);

        XERC20Factory factory = new XERC20Factory();
        wrapper = new WrapperMinter(factory);
        console2.log("new wrapper addr", address(wrapper));
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = UINT256_MAX;
        address[] memory bridges = new address[](1);
        bridges[0] = address(wrapper);

        // Deploy xERC20 versions of cUSDC and APE
        address cxrc20 = wrapper.deployXERC20(cUSDCGoerli, address(0), amounts, amounts, bridges);
        address apexrc20 = wrapper.deployXERC20(apeGoerli, address(0), amounts, amounts, bridges);
        console2.log("new cxrc20 addr", cxrc20);
        console2.log("new apexrc20 addr", apexrc20);
        console2.log("new xerc20 factory addr", address(factory));
        vm.stopBroadcast();
    }
}
