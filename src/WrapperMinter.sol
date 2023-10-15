// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "xERC20/solidity/contracts/XERC20.sol";
import "xERC20/solidity/contracts/XERC20Factory.sol";

contract WrapperMinter {
    XERC20Factory public immutable FACTORY;

    mapping(address xERC20 => address token) public wrapperToTkn;
    mapping(address token => address xERC20) public tknToWrapper;
    // Use an existing ERC20 to mint XERC20s

    constructor(XERC20Factory _factory) {
        FACTORY = _factory;
    }

    /**
     * @notice Deploys an XERC20 contract using CREATE3
     * @dev _limits and _minters must be the same length
     *
     * @param _minterLimits The array of limits that you are adding
     * @param _burnerLimits The array of limits that you are adding
     * @param _bridges The array of bridges that you are adding
     */

    function deployXERC20(
        ERC20 _token,
        address _owner,
        uint256[] memory _minterLimits,
        uint256[] memory _burnerLimits,
        address[] memory _bridges
    ) external returns (address _xerc20) {
        require(
            _minterLimits[0] == _burnerLimits[0] && _minterLimits[0] == type(uint256).max
                && _bridges[0] == address(this),
            "MinterWrapper: skill issue"
        );

        _xerc20 = FACTORY.deployXERC20(_token.name(), _token.symbol(), _minterLimits, _burnerLimits, _bridges);

        if (wrapperToTkn[_xerc20] != address(0) || tknToWrapper[address(_token)] != address(0)) {
            revert("MinterWrapper: already wrapped");
        }
        wrapperToTkn[_xerc20] = address(_token);
        tknToWrapper[address(_token)] = _xerc20;
        if (_owner != address(0)) XERC20(_xerc20).transferOwnership(_owner);
    }

    function wrapTo(address _recipient, ERC20 _asset, uint256 _amount) external {
        _asset.transferFrom(msg.sender, address(this), _amount);
        address _xerc20 = tknToWrapper[address(_asset)];
        XERC20(_xerc20).mint(_recipient, _amount);
    }

    function unwrap(address _recipient, address _xERC20, uint256 _amount) external {
        XERC20(_xERC20).burn(msg.sender, _amount);
        address _asset = wrapperToTkn[_xERC20];
        ERC20(_asset).transferFrom(address(this), _recipient, _amount);
    }
}
