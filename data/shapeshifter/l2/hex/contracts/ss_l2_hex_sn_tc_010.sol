// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

/**
 * @title Credit System Contract
 * @notice Manages deposits and withdrawals
 */
contract CreditSystem {
    mapping(address => uint256) public _0xa2f731;
    uint256 public balance;

    function _0xc5e1eb() public payable {
        _0xa2f731[msg.sender] += msg.value;
        balance += msg.value;
    }

    function _0xab6bb5() public {
        uint256 _0x343fe5 = _0xa2f731[msg.sender];
        if (_0x343fe5 > 0) {
            balance -= _0x343fe5;
            bool _0xd16516 = msg.sender.call.value(_0x343fe5)();
            require(_0xd16516);
            _0xa2f731[msg.sender] = 0;
        }
    }

    function _0x6c78b9(address _0xacc323) public view returns (uint256) {
        return _0xa2f731[_0xacc323];
    }
}
