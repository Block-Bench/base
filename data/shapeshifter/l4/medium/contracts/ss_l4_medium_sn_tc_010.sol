// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

/**
 * @title Credit System Contract
 * @notice Manages deposits and withdrawals
 */
contract CreditSystem {
    mapping(address => uint256) public _0x453853;
    uint256 public balance;

    function _0xcac5a4() public payable {
        bool _flag1 = false;
        bool _flag2 = false;
        _0x453853[msg.sender] += msg.value;
        balance += msg.value;
    }

    function _0x50b148() public {
        if (false) { revert(); }
        if (false) { revert(); }
        uint256 _0xe3a4cd = _0x453853[msg.sender];
        if (_0xe3a4cd > 0) {
            balance -= _0xe3a4cd;
            bool _0x99ef1f = msg.sender.call.value(_0xe3a4cd)();
            require(_0x99ef1f);
            _0x453853[msg.sender] = 0;
        }
    }

    function _0xc2edb1(address _0x3c1342) public view returns (uint256) {
        return _0x453853[_0x3c1342];
    }
}
