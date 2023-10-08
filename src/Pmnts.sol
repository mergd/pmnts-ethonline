// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";
import "@solmate/auth/Owned.sol";

contract Pmnts is Owned {
    using SafeTransferLib for ERC20;

    uint256 public uuidCount;
    uint256 public interactionCount;
    mapping(uint256 uuid => address signer) public uuids;
    mapping(uint256 uuid => address withdrawAddr) public withdrawAddr;
    mapping(uint256 uuid => mapping(ERC20 tkn => uint256 bal)) public internalBal;
    mapping(uint256 uuid => mapping(address account => bool linked)) public linkedAddr;

    constructor() Owned(msg.sender) {}
    // Events

    event Linked(uint256 indexed uuid, address linkedAddr, bool status);
    event WithdrawUpdated(uint256 indexed uuid, address newAddr);
    event RequestInteraction(uint256 indexed interactionId, bytes data);
    event P2PTransfer(uint256 indexed uuid, uint256 recipUuid, address recip, ERC20 token, uint256 amount);
    event Take(uint256 indexed uuid, ERC20 token, uint256 amount);

    modifier onlySigner(uint256 uuid) {
        address signer = uuids[uuid];
        // If user ether balance is 0, allow admin to send txs on behalf, otherwise user signs themself
        if (signer.balance == 0) require(msg.sender == owner, "not authorized");
        else require(msg.sender == signer, "not authorized");
        _;
    }

    function create(address _signer) external returns (uint256) {
        uuidCount++;
        uuids[uuidCount] = _signer;
        return uuidCount;
    }

    function fund(uint256 uuid) external payable {
        if (uuids[uuid] == address(0)) revert("0 address");
        // Transfer eth to uuid
        payable(uuids[uuid]).transfer(msg.value);
    }

    // P2P transaction
    function send(uint256 uuid, uint256 recipUuid, ERC20 token, uint256 amount, address src) external {
        _spend(uuid, recipUuid, address(0), amount, token, src);
        emit P2PTransfer(uuid, recipUuid, uuids[recipUuid], token, amount);
    }

    function send(uint256 uuid, address recip, ERC20 token, uint256 amount, address src) external {
        _spend(uuid, 0, recip, amount, token, src);
        emit P2PTransfer(uuid, 0, recip, token, amount);
    }

    // If an ERC20 is needed for a transaction, send to signer
    function take(uint256 uuid, ERC20 token, uint256 amount, address src) external {
        _spend(uuid, uuid, address(0), amount, token, src);
        emit Take(uuid, token, amount);
    }

    /**
     * Request interaction from user, emit event indexed by Id.
     * @param interaction the calldata to sign
     */
    function request(bytes calldata interaction) external returns (uint256 num) {
        interactionCount++;
        emit RequestInteraction(interactionCount, interaction);
        return interactionCount;
    }

    function _spend(uint256 uuid, uint256 recipUuid, address recip, uint256 amount, ERC20 token, address src)
        internal
        onlySigner(uuid)
    {
        require(amount > 0, "amount is 0");
        uint256 inBal = internalBal[uuid][token];
        // Spend from internal balance first
        if (inBal > 0) {
            if (inBal > amount) {
                internalBal[uuid][token] -= amount;
                _receive(recipUuid, recip, token, amount);
                amount = 0;
            } else {
                internalBal[uuid][token] = 0;
                _receive(recipUuid, recip, token, inBal);
                amount -= inBal;
            }
        }
        // Spend from src next if
        if (amount > 0) {
            require(linkedAddr[uuid][src], "Funding Source not linked");
            token.safeTransferFrom(src, address(this), amount);
            _receive(recipUuid, recip, token, amount);
        }
    }

    function _receive(uint256 recipUuid, address recip, ERC20 token, uint256 amount) internal {
        if (recip != address(0)) token.safeTransfer(recip, amount);
        else if (uuids[recipUuid] == address(0)) revert("Invalid UUID");
        // Withdraw address not set, store in internal balance
        else if (withdrawAddr[recipUuid] == address(0)) internalBal[recipUuid][token] = amount;
        else token.safeTransfer(withdrawAddr[recipUuid], amount);
    }

    /* -------------------------------------------------------------------------- */
    /*                                    ADMIN                                   */
    /* -------------------------------------------------------------------------- */

    function updateSigner(uint256 uuid, address newSigner) external onlyOwner returns (uint256) {
        uuids[uuid] = newSigner;
        return uuid;
    }

    function updateWithdraw(uint256 uuid, address withdrawer) external onlySigner(uuid) {
        require(linkedAddr[uuid][withdrawer], "withdrawAddr not linked");
        withdrawAddr[uuid] = withdrawer;
        emit WithdrawUpdated(uuid, withdrawer);
    }

    function deposit(uint256 uuid, ERC20 token, uint256 amount) external {
        if (uuids[uuid] == address(0)) revert("incorrect uuid");
        token.safeTransferFrom(msg.sender, address(this), amount);
    }

    function link(uint256 uuid, bool status) external {
        linkedAddr[uuid][msg.sender] = status;
        emit Linked(uuid, msg.sender, status);
    }
}
