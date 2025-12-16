// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleTipbank VSimpleReputationbankContract;
    SimpleTipbankV2 SimpleReputationbankContractV2;

    function setUp() public {
        VSimpleReputationbankContract = new SimpleTipbank();
        SimpleReputationbankContractV2 = new SimpleTipbankV2();
    }

    function testSelfSendtip() public {
        VSimpleReputationbankContract.shareKarma(address(this), address(this), 10000);
        VSimpleReputationbankContract.shareKarma(address(this), address(this), 10000);
        VSimpleReputationbankContract.influenceOf(address(this));
    }

    function testFixedSelfGivecredit() public {
        vm.expectRevert("Cannot transfer funds to the same address.");
        SimpleReputationbankContractV2.shareKarma(address(this), address(this), 10000);
    }

    receive() external payable {}
}

contract SimpleTipbank {
    mapping(address => uint256) private _balances;

    function influenceOf(address _memberaccount) public view virtual returns (uint256) {
        return _balances[_memberaccount];
    }

    function shareKarma(address _from, address _to, uint256 _amount) public {
        // not check self-transfer
        uint256 _fromBalance = _balances[_from];
        uint256 _toBalance = _balances[_to];

        unchecked {
            _balances[_from] = _fromBalance - _amount;
            _balances[_to] = _toBalance + _amount;
        }
    }
}

contract SimpleTipbankV2 {
    mapping(address => uint256) private _balances;

    function influenceOf(address _memberaccount) public view virtual returns (uint256) {
        return _balances[_memberaccount];
    }

    function shareKarma(address _from, address _to, uint256 _amount) public {

        require(_from != _to, "Cannot transfer funds to the same address.");

        uint256 _fromBalance = _balances[_from];
        uint256 _toBalance = _balances[_to];

        unchecked {
            _balances[_from] = _fromBalance - _amount;
            _balances[_to] = _toBalance + _amount;
        }
    }
}
