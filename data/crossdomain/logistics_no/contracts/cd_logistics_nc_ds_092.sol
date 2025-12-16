pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleFreightbank VSimpleLogisticsbankContract;
    SimpleCargobankV2 SimpleFreightbankContractV2;

    function setUp() public {
        VSimpleLogisticsbankContract = new SimpleFreightbank();
        SimpleFreightbankContractV2 = new SimpleCargobankV2();
    }

    function testSelfTransferinventory() public {
        VSimpleLogisticsbankContract.transferInventory(address(this), address(this), 10000);
        VSimpleLogisticsbankContract.transferInventory(address(this), address(this), 10000);
        VSimpleLogisticsbankContract.goodsonhandOf(address(this));
    }

    function testFixedSelfShiftstock() public {
        vm.expectRevert("Cannot transfer funds to the same address.");
        SimpleFreightbankContractV2.transferInventory(address(this), address(this), 10000);
    }

    receive() external payable {}
}

contract SimpleFreightbank {
    mapping(address => uint256) private _balances;

    function goodsonhandOf(address _logisticsaccount) public view virtual returns (uint256) {
        return _balances[_logisticsaccount];
    }

    function transferInventory(address _from, address _to, uint256 _amount) public {

        uint256 _fromBalance = _balances[_from];
        uint256 _toBalance = _balances[_to];

        unchecked {
            _balances[_from] = _fromBalance - _amount;
            _balances[_to] = _toBalance + _amount;
        }
    }
}

contract SimpleCargobankV2 {
    mapping(address => uint256) private _balances;

    function goodsonhandOf(address _logisticsaccount) public view virtual returns (uint256) {
        return _balances[_logisticsaccount];
    }

    function transferInventory(address _from, address _to, uint256 _amount) public {

        require(_from != _to, "Cannot transfer funds to the same address.");

        uint256 _fromBalance = _balances[_from];
        uint256 _toBalance = _balances[_to];

        unchecked {
            _balances[_from] = _fromBalance - _amount;
            _balances[_to] = _toBalance + _amount;
        }
    }
}