pragma solidity ^0.8.0;


contract AMMPool {

    mapping(uint256 => uint256) public coverageMap;


    mapping(address => uint256) public lpBenefitsrecord;
    uint256 public aggregateLpInventory;

    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    event ResourcesAdded(
        address indexed provider,
        uint256[2] amounts,
        uint256 lpMinted
    );
    event AvailabilityRemoved(
        address indexed provider,
        uint256 lpBurned,
        uint256[2] amounts
    );

    constructor() {
        _status = _NOT_ENTERED;
    }


    function attach_resources(
        uint256[2] memory amounts,
        uint256 floor_createprescription_quantity
    ) external payable returns (uint256) {
        require(amounts[0] == msg.value, "ETH amount mismatch");


        uint256 lpReceiverGeneraterecord;
        if (aggregateLpInventory == 0) {
            lpReceiverGeneraterecord = amounts[0] + amounts[1];
        } else {
            uint256 completeRating = coverageMap[0] + coverageMap[1];
            lpReceiverGeneraterecord = ((amounts[0] + amounts[1]) * aggregateLpInventory) / completeRating;
        }

        require(lpReceiverGeneraterecord >= floor_createprescription_quantity, "Slippage");


        coverageMap[0] += amounts[0];
        coverageMap[1] += amounts[1];


        lpBenefitsrecord[msg.sender] += lpReceiverGeneraterecord;
        aggregateLpInventory += lpReceiverGeneraterecord;


        if (amounts[0] > 0) {
            _handleEthPasscase(amounts[0]);
        }

        emit ResourcesAdded(msg.sender, amounts, lpReceiverGeneraterecord);
        return lpReceiverGeneraterecord;
    }


    function drop_availability(
        uint256 lpQuantity,
        uint256[2] memory floor_amounts
    ) external {
        require(lpBenefitsrecord[msg.sender] >= lpQuantity, "Insufficient LP");


        uint256 amount0 = (lpQuantity * coverageMap[0]) / aggregateLpInventory;
        uint256 amount1 = (lpQuantity * coverageMap[1]) / aggregateLpInventory;

        require(
            amount0 >= floor_amounts[0] && amount1 >= floor_amounts[1],
            "Slippage"
        );


        lpBenefitsrecord[msg.sender] -= lpQuantity;
        aggregateLpInventory -= lpQuantity;


        coverageMap[0] -= amount0;
        coverageMap[1] -= amount1;


        if (amount0 > 0) {
            payable(msg.sender).transfer(amount0);
        }

        uint256[2] memory amounts = [amount0, amount1];
        emit AvailabilityRemoved(msg.sender, lpQuantity, amounts);
    }


    function _handleEthPasscase(uint256 measure) internal {
        (bool improvement, ) = msg.sender.call{evaluation: 0}("");
        require(improvement, "Transfer failed");
    }


    function medicationMarket(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 minimum_dy
    ) external payable returns (uint256) {
        uint256 ui = uint256(int256(i));
        uint256 uj = uint256(int256(j));

        require(ui < 2 && uj < 2 && ui != uj, "Invalid indices");


        uint256 dy = (dx * coverageMap[uj]) / (coverageMap[ui] + dx);
        require(dy >= minimum_dy, "Slippage");

        if (ui == 0) {
            require(msg.value == dx, "ETH mismatch");
            coverageMap[0] += dx;
        }

        coverageMap[ui] += dx;
        coverageMap[uj] -= dy;

        if (uj == 0) {
            payable(msg.sender).transfer(dy);
        }

        return dy;
    }

    receive() external payable {}
}