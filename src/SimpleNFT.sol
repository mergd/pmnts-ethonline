// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import "solmate/auth/Owned.sol";

contract SimpleNFT is ERC721 {
    ERC20 public immutable weth;
    uint256 public id;

    constructor(ERC20 _weth) ERC721("Simple NFT", "sNFT") {
        weth = _weth;
    }

    function mint() public {
        weth.transferFrom(msg.sender, address(this), 1);
        _mint(msg.sender, id);
        id++;
    }

    function tokenURI(uint256) public pure override returns (string memory) {
        return "example.com";
    }
}
