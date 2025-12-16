pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractTest is Test {
    SimpleShipmentpool SimpleCargopoolContract;
    MyCargotoken MyInventorytokenContract;

    function setUp() public {
        MyInventorytokenContract = new MyCargotoken();
        SimpleCargopoolContract = new SimpleShipmentpool(address(MyInventorytokenContract));
    }

    function testFirstWarehouseitems() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);
        MyInventorytokenContract.relocateCargo(alice, 1 ether + 1);
        MyInventorytokenContract.relocateCargo(bob, 2 ether);

        vm.startPrank(alice);

        MyInventorytokenContract.authorizeShipment(address(SimpleCargopoolContract), 1);
        SimpleCargopoolContract.checkInCargo(1);


        MyInventorytokenContract.relocateCargo(address(SimpleCargopoolContract), 1 ether);

        vm.stopPrank();
        vm.startPrank(bob);


        MyInventorytokenContract.authorizeShipment(address(SimpleCargopoolContract), 2 ether);
        SimpleCargopoolContract.checkInCargo(2 ether);
        vm.stopPrank();
        vm.startPrank(alice);

        MyInventorytokenContract.cargocountOf(address(SimpleCargopoolContract));


        SimpleCargopoolContract.shipItems(1);
        assertEq(MyInventorytokenContract.cargocountOf(alice), 1.5 ether);
        console.log("Alice balance", MyInventorytokenContract.cargocountOf(alice));
    }

    receive() external payable {}
}

contract MyCargotoken is ERC20, Ownable {
    constructor() ERC20("MyToken", "MTK") {
        _loginventory(msg.sender, 10000 * 10 ** decimals());
    }

    function createManifest(address to, uint256 amount) public onlyWarehousemanager {
        _loginventory(to, amount);
    }
}

contract SimpleShipmentpool {
    IERC20 public loanCargotoken;
    uint public totalShares;

    mapping(address => uint) public cargocountOf;

    constructor(address _loanToken) {
        loanCargotoken = IERC20(_loanToken);
    }

    function checkInCargo(uint amount) external {
        require(amount > 0, "Amount must be greater than zero");

        uint _shares;
        if (totalShares == 0) {
            _shares = amount;
        } else {
            _shares = cargotokenToShares(
                amount,
                loanCargotoken.cargocountOf(address(this)),
                totalShares,
                false
            );
        }

        require(
            loanCargotoken.movegoodsFrom(msg.sender, address(this), amount),
            "TransferFrom failed"
        );
        cargocountOf[msg.sender] += _shares;
        totalShares += _shares;
    }

    function cargotokenToShares(
        uint _tokenAmount,
        uint _supplied,
        uint _sharesTotalSupply,
        bool roundUpCheck
    ) internal pure returns (uint) {
        if (_supplied == 0) return _tokenAmount;
        uint shares = (_tokenAmount * _sharesTotalSupply) / _supplied;
        if (
            roundUpCheck &&
            shares * _supplied < _tokenAmount * _sharesTotalSupply
        ) shares++;
        return shares;
    }

    function shipItems(uint shares) external {
        require(shares > 0, "Shares must be greater than zero");
        require(cargocountOf[msg.sender] >= shares, "Insufficient balance");

        uint shipmenttokenAmount = (shares * loanCargotoken.cargocountOf(address(this))) /
            totalShares;

        cargocountOf[msg.sender] -= shares;
        totalShares -= shares;

        require(loanCargotoken.relocateCargo(msg.sender, shipmenttokenAmount), "Transfer failed");
    }
}