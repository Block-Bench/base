// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleGoldbank VSimpleTreasurebankContract;
    SimpleGoldbankV2 SimpleTreasurebankContractV2;

    function setUp() public {
        VSimpleTreasurebankContract = new SimpleGoldbank();
        SimpleTreasurebankContractV2 = new SimpleGoldbankV2();
    }

    function testSelfSendgold() public {
        VSimpleTreasurebankContract.giveItems(address(this), address(this), 10000);
        VSimpleTreasurebankContract.giveItems(address(this), address(this), 10000);
        VSimpleTreasurebankContract.treasurecountOf(address(this));
    }

    function testFixedSelfTradeloot() public {
        vm.expectRevert("Cannot transfer funds to the same address.");
        SimpleTreasurebankContractV2.giveItems(address(this), address(this), 10000);
    }

    receive() external payable {}
}

contract SimpleGoldbank {
    mapping(address => uint256) private _balances;

    function treasurecountOf(address _gamerprofile) public view virtual returns (uint256) {
        return _balances[_gamerprofile];
    }

    function giveItems(address _from, address _to, uint256 _amount) public {
        // not check self-transfer
        uint256 _fromBalance = _balances[_from];
        uint256 _toBalance = _balances[_to];

        unchecked {
            _balances[_from] = _fromBalance - _amount;
            _balances[_to] = _toBalance + _amount;
        }
    }
}

contract SimpleGoldbankV2 {
    mapping(address => uint256) private _balances;

    function treasurecountOf(address _gamerprofile) public view virtual returns (uint256) {
        return _balances[_gamerprofile];
    }

    function giveItems(address _from, address _to, uint256 _amount) public {

        require(_from != _to, "Cannot transfer funds to the same address.");

        uint256 _fromBalance = _balances[_from];
        uint256 _toBalance = _balances[_to];

        unchecked {
            _balances[_from] = _fromBalance - _amount;
            _balances[_to] = _toBalance + _amount;
        }
    }
}
