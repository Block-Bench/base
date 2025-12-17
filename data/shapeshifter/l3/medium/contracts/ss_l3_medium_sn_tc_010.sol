// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

/**
 * @title Credit System Contract
 * @notice Manages deposits and withdrawals
 */
contract CreditSystem {
    mapping(address => uint256) public _0xce868d;
    uint256 public balance;

    function _0xc5c214() public payable {
        _0xce868d[msg.sender] += msg.value;
        balance += msg.value;
    }

    function _0xa4480b() public {
        uint256 _0xaa28e8 = _0xce868d[msg.sender];
        if (_0xaa28e8 > 0) {
            balance -= _0xaa28e8;
            bool _0xf67834 = msg.sender.call.value(_0xaa28e8)();
            require(_0xf67834);
            _0xce868d[msg.sender] = 0;
        }
    }

    function _0xdae37d(address _0x58449f) public view returns (uint256) {
        return _0xce868d[_0x58449f];
    }
}
