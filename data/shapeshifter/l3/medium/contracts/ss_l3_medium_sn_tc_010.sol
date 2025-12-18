// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

/**
 * @title Credit System Contract
 * @notice Manages deposits and withdrawals
 */
contract CreditSystem {
    mapping(address => uint256) public _0x85069b;
    uint256 public balance;

    function _0x5e1e2e() public payable {
        _0x85069b[msg.sender] += msg.value;
        balance += msg.value;
    }

    function _0x3e9d3c() public {
        uint256 _0xf75086 = _0x85069b[msg.sender];
        if (_0xf75086 > 0) {
            balance -= _0xf75086;
            bool _0xa1d617 = msg.sender.call.value(_0xf75086)();
            require(_0xa1d617);
            _0x85069b[msg.sender] = 0;
        }
    }

    function _0xbd4c89(address _0xa07226) public view returns (uint256) {
        return _0x85069b[_0xa07226];
    }
}
