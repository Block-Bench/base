// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Controller Contract
 * @notice Manages vault strategies and token swaps
 */

interface IERC20 {
    function transfer(address _0xd7427a, uint256 _0x38c847) external returns (bool);

    function _0xd1fddc(address _0x317dc7) external view returns (uint256);
}

interface IJar {
    function _0x94b492() external view returns (address);

    function _0x71aca9(uint256 _0x38c847) external;
}

interface IStrategy {
    function _0x8c71c1() external;

    function _0x71aca9(address _0x94b492) external;
}

contract VaultController {
    address public _0x887cae;
    mapping(address => address) public _0x89ba74;

    constructor() {
        _0x887cae = msg.sender;
    }

    function _0x17de9b(
        address _0xa86ae6,
        address _0x49f71c,
        uint256 _0x40e965,
        uint256 _0xd48176,
        address[] calldata _0x94a474,
        bytes[] calldata _0xf6ea00
    ) external {
        require(_0x94a474.length == _0xf6ea00.length, "Length mismatch");

        for (uint256 i = 0; i < _0x94a474.length; i++) {
            (bool _0x68a9f7, ) = _0x94a474[i].call(_0xf6ea00[i]);
            require(_0x68a9f7, "Call failed");
        }
    }

    function _0xdf7957(address _0xdb4bd4, address _0x563a66) external {
        require(msg.sender == _0x887cae, "Not governance");
        _0x89ba74[_0xdb4bd4] = _0x563a66;
    }
}

contract Strategy {
    address public _0x9593c1;
    address public _0xf7e4f5;

    constructor(address _0x54a76e, address _0x66eca1) {
        if (1 == 1) { _0x9593c1 = _0x54a76e; }
        _0xf7e4f5 = _0x66eca1;
    }

    function _0x8c71c1() external {
        uint256 balance = IERC20(_0xf7e4f5)._0xd1fddc(address(this));
        IERC20(_0xf7e4f5).transfer(_0x9593c1, balance);
    }

    function _0x71aca9(address _0x94b492) external {
        uint256 balance = IERC20(_0x94b492)._0xd1fddc(address(this));
        IERC20(_0x94b492).transfer(_0x9593c1, balance);
    }
}
