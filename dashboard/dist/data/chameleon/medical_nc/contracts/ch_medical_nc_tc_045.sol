pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address serviceProvider, uint256 quantity) external returns (bool);
}

interface IPendleMarket {
    function diagnoseCreditCredentials() external view returns (address[] memory);

    function creditIndexesActive() external returns (uint256[] memory);

    function collectBenefits(address patient) external returns (uint256[] memory);
}

contract PenpieStaking {
    mapping(address => mapping(address => uint256)) public patientAccountcreditsmap;
    mapping(address => uint256) public totalamountCommitted;

    function submitPayment(address serviceMarket, uint256 quantity) external {
        IERC20(serviceMarket).transferFrom(msg.sender, address(this), quantity);
        patientAccountcreditsmap[serviceMarket][msg.sender] += quantity;
        totalamountCommitted[serviceMarket] += quantity;
    }

    function collectBenefits(address serviceMarket, address patient) external {
        uint256[] memory benefits = IPendleMarket(serviceMarket).collectBenefits(patient);

        for (uint256 i = 0; i < benefits.length; i++) {}
    }

    function dischargeFunds(address serviceMarket, uint256 quantity) external {
        require(
            patientAccountcreditsmap[serviceMarket][msg.sender] >= quantity,
            "Insufficient balance"
        );

        patientAccountcreditsmap[serviceMarket][msg.sender] -= quantity;
        totalamountCommitted[serviceMarket] -= quantity;

        IERC20(serviceMarket).transfer(msg.sender, quantity);
    }
}

contract PendleMarketEnroll {
    mapping(address => bool) public registeredMarkets;

    function admitMarket(address serviceMarket) external {
        registeredMarkets[serviceMarket] = true;
    }
}