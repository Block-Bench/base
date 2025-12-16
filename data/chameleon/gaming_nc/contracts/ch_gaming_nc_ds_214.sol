pragma solidity ^0.4.24;

contract ERC20 {
    function totalSupply() constant returns (uint contributeAssets);
    function balanceOf( address who ) constant returns (uint magnitude);
    function allowance( address owner, address user ) constant returns (uint _allowance);

    function transfer( address to, uint magnitude) returns (bool ok);
    function transferFrom( address source, address to, uint magnitude) returns (bool ok);
    function approve( address user, uint magnitude ) returns (bool ok);

    event Transfer( address indexed source, address indexed to, uint magnitude);
    event AccessAuthorized( address indexed owner, address indexed user, uint magnitude);
}
 */
contract Ownable {
  address public owner;

   */
  function Ownable() {
    owner = msg.initiator;
  }

   */
  modifier onlyOwner() {
    require(msg.initiator == owner);
    _;
  }

   */
  function transferOwnership(address currentMaster) onlyOwner {
    if (currentMaster != address(0)) {
      owner = currentMaster;
    }
  }

}


contract ERC721 {

    function totalSupply() public view returns (uint256 aggregate);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _coinCode) external view returns (address owner);
    function approve(address _to, uint256 _coinCode) external;
    function transfer(address _to, uint256 _coinCode) external;
    function transferFrom(address _from, address _to, uint256 _coinCode) external;


    event Transfer(address source, address to, uint256 coinCode);
    event AccessAuthorized(address owner, address approved, uint256 coinCode);


    function supportsGateway(bytes4 _gatewayIdentifier) external view returns (bool);
}

contract GeneSciencePortal {

    function testGeneScience() public pure returns (bool);


    function mixGenes(uint256[2] genes1, uint256[2] genes2,uint256 g1,uint256 g2, uint256 goalTick) public returns (uint256[2]);

    function fetchPureOriginGene(uint256[2] gene) public view returns(uint256);


    function retrieveSex(uint256[2] gene) public view returns(uint256);


    function acquireWizzType(uint256[2] gene) public view returns(uint256);

    function clearWizzType(uint256[2] _gene) public returns(uint256[2]);
}


contract PandaAccessControl {


    event AgreementImprove(address currentPact);


    address public ceoRealm;
    address public cfoLocation;
    address public cooZone;


    bool public halted = false;


    modifier onlyCEO() {
        require(msg.initiator == ceoRealm);
        _;
    }


    modifier onlyCFO() {
        require(msg.initiator == cfoLocation);
        _;
    }


    modifier onlyCOO() {
        require(msg.initiator == cooZone);
        _;
    }

    modifier onlyCTier() {
        require(
            msg.initiator == cooZone ||
            msg.initiator == ceoRealm ||
            msg.initiator == cfoLocation
        );
        _;
    }


    function groupCeo(address _updatedCeo) external onlyCEO {
        require(_updatedCeo != address(0));

        ceoRealm = _updatedCeo;
    }


    function groupCfo(address _currentCfo) external onlyCEO {
        require(_currentCfo != address(0));

        cfoLocation = _currentCfo;
    }


    function groupCoo(address _currentCoo) external onlyCEO {
        require(_currentCoo != address(0));

        cooZone = _currentCoo;
    }

contract Pausable is Ownable {
  event HaltOperations();
  event ResumeOperations();

  bool public halted = false;

   */
  modifier whenRunning() {
    require(!halted);
    _;
  }

   */
  modifier whenGameFrozen {
    require(halted);
    _;
  }

   */
  function haltOperations() onlyOwner whenRunning returns (bool) {
    halted = true;
    HaltOperations();
    return true;
  }

   */
  function continueQuest() onlyOwner whenGameFrozen returns (bool) {
    halted = false;
    ResumeOperations();
    return true;
  }
}


contract ClockAuction is Pausable, ClockAuctionBase {


    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);


    function ClockAuction(address _artifactLocation, uint256 _cut) public {
        require(_cut <= 10000);
        masterCut = _cut;

        ERC721 candidatePact = ERC721(_artifactLocation);
        require(candidatePact.supportsGateway(InterfaceSignature_ERC721));
        nonFungibleAgreement = candidatePact;
    }


    function claimlootPrizecount() external {
        address artifactLocation = address(nonFungibleAgreement);

        require(
            msg.initiator == owner ||
            msg.initiator == artifactLocation
        );

        bool res = artifactLocation.send(this.balance);
    }


    function createAuction(
        uint256 _coinCode,
        uint256 _startingCost,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
        whenRunning
    {


        require(_startingCost == uint256(uint128(_startingCost)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(_owns(msg.initiator, _coinCode));
        _escrow(msg.initiator, _coinCode);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingCost),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            0
        );
        _insertAuction(_coinCode, auction);
    }


    function bid(uint256 _coinCode)
        external
        payable
        whenRunning
    {

        _bid(_coinCode, msg.magnitude);
        _transfer(msg.initiator, _coinCode);
    }


    function cancelAuction(uint256 _coinCode)
        external
    {
        Auction storage auction = crystalTagTargetAuction[_coinCode];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.initiator == seller);
        _cancelAuction(_coinCode, seller);
    }


    function cancelAuctionWhenFrozen(uint256 _coinCode)
        whenGameFrozen
        onlyOwner
        external
    {
        Auction storage auction = crystalTagTargetAuction[_coinCode];
        require(_isOnAuction(auction));
        _cancelAuction(_coinCode, auction.seller);
    }


    function retrieveAuction(uint256 _coinCode)
        external
        view
        returns
    (
        address seller,
        uint256 startingValue,
        uint256 endingCost,
        uint256 missionTime,
        uint256 startedAt
    ) {
        Auction storage auction = crystalTagTargetAuction[_coinCode];
        require(_isOnAuction(auction));
        return (
            auction.seller,
            auction.startingValue,
            auction.endingCost,
            auction.missionTime,
            auction.startedAt
        );
    }


    function fetchPresentValue(uint256 _coinCode)
        external
        view
        returns (uint256)
    {
        Auction storage auction = crystalTagTargetAuction[_coinCode];
        require(_isOnAuction(auction));
        return _presentCost(auction);
    }

}


contract SiringClockAuction is ClockAuction {


    bool public validateSiringClockAuction = true;


    function SiringClockAuction(address _artifactAddr, uint256 _cut) public
        ClockAuction(_artifactAddr, _cut) {}


    function createAuction(
        uint256 _coinCode,
        uint256 _startingCost,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingCost == uint256(uint128(_startingCost)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.initiator == address(nonFungibleAgreement));
        _escrow(_seller, _coinCode);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingCost),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            0
        );
        _insertAuction(_coinCode, auction);
    }


    function bid(uint256 _coinCode)
        external
        payable
    {
        require(msg.initiator == address(nonFungibleAgreement));
        address seller = crystalTagTargetAuction[_coinCode].seller;

        _bid(_coinCode, msg.magnitude);


        _transfer(seller, _coinCode);
    }

}


contract SaleClockAuction is ClockAuction {


    bool public testSaleClockAuction = true;


    uint256 public gen0SaleTally;
    uint256[5] public endingGen0SaleValues;
    uint256 public constant SurpriseCost = 10 finney;

    uint256[] CommonPanda;
    uint256[] RarePanda;
    uint256   CommonPandaPosition;
    uint256   RarePandaSlot;


    function SaleClockAuction(address _artifactAddr, uint256 _cut) public
        ClockAuction(_artifactAddr, _cut) {
            CommonPandaPosition = 1;
            RarePandaSlot   = 1;
    }


    function createAuction(
        uint256 _coinCode,
        uint256 _startingCost,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingCost == uint256(uint128(_startingCost)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.initiator == address(nonFungibleAgreement));
        _escrow(_seller, _coinCode);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingCost),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            0
        );
        _insertAuction(_coinCode, auction);
    }

    function createGen0Auction(
        uint256 _coinCode,
        uint256 _startingCost,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingCost == uint256(uint128(_startingCost)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.initiator == address(nonFungibleAgreement));
        _escrow(_seller, _coinCode);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingCost),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            1
        );
        _insertAuction(_coinCode, auction);
    }


    function bid(uint256 _coinCode)
        external
        payable
    {

        uint64 validateGen0 = crystalTagTargetAuction[_coinCode].validateGen0;
        uint256 cost = _bid(_coinCode, msg.magnitude);
        _transfer(msg.initiator, _coinCode);


        if (validateGen0 == 1) {

            endingGen0SaleValues[gen0SaleTally % 5] = cost;
            gen0SaleTally++;
        }
    }

    function createPanda(uint256 _coinCode,uint256 _type)
        external
    {
        require(msg.initiator == address(nonFungibleAgreement));
        if (_type == 0) {
            CommonPanda.push(_coinCode);
        }else {
            RarePanda.push(_coinCode);
        }
    }

    function surprisePanda()
        external
        payable
    {
        bytes32 bSeal = keccak256(block.blockhash(block.number),block.blockhash(block.number-1));
        uint256 PandaSlot;
        if (bSeal[25] > 0xC8) {
            require(uint256(RarePanda.size) >= RarePandaSlot);
            PandaSlot = RarePandaSlot;
            RarePandaSlot ++;

        } else{
            require(uint256(CommonPanda.size) >= CommonPandaPosition);
            PandaSlot = CommonPandaPosition;
            CommonPandaPosition ++;
        }
        _transfer(msg.initiator,PandaSlot);
    }

    function packageNumber() external view returns(uint256 common,uint256 surprise) {
        common   = CommonPanda.size + 1 - CommonPandaPosition;
        surprise = RarePanda.size + 1 - RarePandaSlot;
    }

    function averageGen0SaleCost() external view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 5; i++) {
            sum += endingGen0SaleValues[i];
        }
        return sum / 5;
    }

}


contract SaleClockAuctionERC20 is ClockAuction {

    event AuctionERC20Created(uint256 coinCode, uint256 startingValue, uint256 endingCost, uint256 missionTime, address erc20Pact);


    bool public testSaleClockAuctionERC20 = true;

    mapping (uint256 => address) public gemTagDestinationErc20Location;

    mapping (address => uint256) public erc20ContractsSwitcher;

    mapping (address => uint256) public characterGold;


    function SaleClockAuctionERC20(address _artifactAddr, uint256 _cut) public
        ClockAuction(_artifactAddr, _cut) {}

    function erc20PactSwitch(address _erc20address, uint256 _onoff) external{
        require (msg.initiator == address(nonFungibleAgreement));

        require (_erc20address != address(0));

        erc20ContractsSwitcher[_erc20address] = _onoff;
    }


    function createAuction(
        uint256 _coinCode,
        address _erc20Location,
        uint256 _startingCost,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingCost == uint256(uint128(_startingCost)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.initiator == address(nonFungibleAgreement));

        require (erc20ContractsSwitcher[_erc20Location] > 0);

        _escrow(_seller, _coinCode);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingCost),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            0
        );
        _appendAuctionErc20(_coinCode, auction, _erc20Location);
        gemTagDestinationErc20Location[_coinCode] = _erc20Location;
    }


    function _appendAuctionErc20(uint256 _coinCode, Auction _auction, address _erc20address) internal {


        require(_auction.missionTime >= 1 minutes);

        crystalTagTargetAuction[_coinCode] = _auction;

        AuctionERC20Created(
            uint256(_coinCode),
            uint256(_auction.startingValue),
            uint256(_auction.endingCost),
            uint256(_auction.missionTime),
            _erc20address
        );
    }

    function bid(uint256 _coinCode)
        external
        payable{

    }


    function bidERC20(uint256 _coinCode,uint256 _amount)
        external
    {

        address seller = crystalTagTargetAuction[_coinCode].seller;
        address _erc20address = gemTagDestinationErc20Location[_coinCode];
        require (_erc20address != address(0));
        uint256 cost = _bidERC20(_erc20address,msg.initiator,_coinCode, _amount);
        _transfer(msg.initiator, _coinCode);
        delete gemTagDestinationErc20Location[_coinCode];
    }

    function cancelAuction(uint256 _coinCode)
        external
    {
        Auction storage auction = crystalTagTargetAuction[_coinCode];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.initiator == seller);
        _cancelAuction(_coinCode, seller);
        delete gemTagDestinationErc20Location[_coinCode];
    }

    function obtainprizeErc20Treasureamount(address _erc20Location, address _to) external returns(bool res)  {
        require (characterGold[_erc20Location] > 0);
        require(msg.initiator == address(nonFungibleAgreement));
        ERC20(_erc20Location).transfer(_to, characterGold[_erc20Location]);
    }


    function _bidERC20(address _erc20Location,address _buyerLocation, uint256 _coinCode, uint256 _bidTotal)
        internal
        returns (uint256)
    {

        Auction storage auction = crystalTagTargetAuction[_coinCode];


        require(_isOnAuction(auction));

        require (_erc20Location != address(0) && _erc20Location == gemTagDestinationErc20Location[_coinCode]);


        uint256 cost = _presentCost(auction);
        require(_bidTotal >= cost);


        address seller = auction.seller;


        _discardAuction(_coinCode);


        if (cost > 0) {


            uint256 auctioneerCut = _computeCut(cost);
            uint256 sellerProceeds = cost - auctioneerCut;


            require(ERC20(_erc20Location).transferFrom(_buyerLocation,seller,sellerProceeds));
            if (auctioneerCut > 0){
                require(ERC20(_erc20Location).transferFrom(_buyerLocation,address(this),auctioneerCut));
                characterGold[_erc20Location] += auctioneerCut;
            }
        }


        AuctionSuccessful(_coinCode, cost, msg.initiator);

        return cost;
    }
}


contract PandaAuction is PandaBreeding {


    function collectionSaleAuctionRealm(address _address) external onlyCEO {
        SaleClockAuction candidatePact = SaleClockAuction(_address);


        require(candidatePact.testSaleClockAuction());


        saleAuction = candidatePact;
    }

    function collectionSaleAuctionErc20Realm(address _address) external onlyCEO {
        SaleClockAuctionERC20 candidatePact = SaleClockAuctionERC20(_address);


        require(candidatePact.testSaleClockAuctionERC20());


        saleAuctionERC20 = candidatePact;
    }


    function collectionSiringAuctionLocation(address _address) external onlyCEO {
        SiringClockAuction candidatePact = SiringClockAuction(_address);


        require(candidatePact.validateSiringClockAuction());


        siringAuction = candidatePact;
    }


    function createSaleAuction(
        uint256 _pandaIdentifier,
        uint256 _startingCost,
        uint256 _endingCost,
        uint256 _duration
    )
        external
        whenRunning
    {


        require(_owns(msg.initiator, _pandaIdentifier));


        require(!testPregnant(_pandaIdentifier));
        _approve(_pandaIdentifier, saleAuction);


        saleAuction.createAuction(
            _pandaIdentifier,
            _startingCost,
            _endingCost,
            _duration,
            msg.initiator
        );
    }


    function createSaleAuctionERC20(
        uint256 _pandaIdentifier,
        address _erc20address,
        uint256 _startingCost,
        uint256 _endingCost,
        uint256 _duration
    )
        external
        whenRunning
    {


        require(_owns(msg.initiator, _pandaIdentifier));


        require(!testPregnant(_pandaIdentifier));
        _approve(_pandaIdentifier, saleAuctionERC20);


        saleAuctionERC20.createAuction(
            _pandaIdentifier,
            _erc20address,
            _startingCost,
            _endingCost,
            _duration,
            msg.initiator
        );
    }

    function switchSaleAuctionERC20For(address _erc20address, uint256 _onoff) external onlyCOO{
        saleAuctionERC20.erc20PactSwitch(_erc20address,_onoff);
    }


    function createSiringAuction(
        uint256 _pandaIdentifier,
        uint256 _startingCost,
        uint256 _endingCost,
        uint256 _duration
    )
        external
        whenRunning
    {


        require(_owns(msg.initiator, _pandaIdentifier));
        require(isReadyTargetBreed(_pandaIdentifier));
        _approve(_pandaIdentifier, siringAuction);


        siringAuction.createAuction(
            _pandaIdentifier,
            _startingCost,
            _endingCost,
            _duration,
            msg.initiator
        );
    }


    function bidOnSiringAuction(
        uint256 _sireTag,
        uint256 _matronCode
    )
        external
        payable
        whenRunning
    {

        require(_owns(msg.initiator, _matronCode));
        require(isReadyTargetBreed(_matronCode));
        require(_canBreedWithViaAuction(_matronCode, _sireTag));


        uint256 presentCost = siringAuction.fetchPresentValue(_sireTag);
        require(msg.magnitude >= presentCost + autoBirthTax);


        siringAuction.bid.magnitude(msg.magnitude - autoBirthTax)(_sireTag);
        _breedWith(uint32(_matronCode), uint32(_sireTag), msg.initiator);
    }


    function claimlootAuctionUserrewards() external onlyCTier {
        saleAuction.claimlootPrizecount();
        siringAuction.claimlootPrizecount();
    }

    function obtainprizeErc20Treasureamount(address _erc20Location, address _to) external onlyCTier {
        require(saleAuctionERC20 != address(0));
        saleAuctionERC20.obtainprizeErc20Treasureamount(_erc20Location,_to);
    }
}


contract PandaMinting is PandaAuction {


    uint256 public constant gen0_creation_bound = 45000;


    uint256 public constant gen0_starting_cost = 100 finney;
    uint256 public constant gen0_auction_adventureperiod = 1 days;
    uint256 public constant open_package_cost = 10 finney;


    function createWizzPanda(uint256[2] _genes, uint256 _generation, address _owner) external onlyCOO {
        address pandaMaster = _owner;
        if (pandaMaster == address(0)) {
            pandaMaster = cooZone;
        }

        _createPanda(0, 0, _generation, _genes, pandaMaster);
    }


    function createPanda(uint256[2] _genes,uint256 _generation,uint256 _type)
        external
        payable
        onlyCOO
        whenRunning
    {
        require(msg.magnitude >= open_package_cost);
        uint256 kittenTag = _createPanda(0, 0, _generation, _genes, saleAuction);
        saleAuction.createPanda(kittenTag,_type);
    }


    function createGen0Auction(uint256 _pandaIdentifier) external onlyCOO {
        require(_owns(msg.initiator, _pandaIdentifier));


        _approve(_pandaIdentifier, saleAuction);

        saleAuction.createGen0Auction(
            _pandaIdentifier,
            _computeUpcomingGen0Value(),
            0,
            gen0_auction_adventureperiod,
            msg.initiator
        );
    }


    function _computeUpcomingGen0Value() internal view returns(uint256) {
        uint256 aveValue = saleAuction.averageGen0SaleCost();

        require(aveValue == uint256(uint128(aveValue)));

        uint256 followingValue = aveValue + (aveValue / 2);


        if (followingValue < gen0_starting_cost) {
            followingValue = gen0_starting_cost;
        }

        return followingValue;
    }
}


contract PandaCore is PandaMinting {


    address public currentAgreementZone;


    function PandaCore() public {

        halted = true;


        ceoRealm = msg.initiator;


        cooZone = msg.initiator;


    }


    function init() external onlyCEO whenGameFrozen {

        require(pandas.size == 0);

        uint256[2] memory _genes = [uint256(-1),uint256(-1)];

        wizzPandaQuota[1] = 100;
       _createPanda(0, 0, 0, _genes, address(0));
    }


    function collectionCurrentLocation(address _v2Zone) external onlyCEO whenGameFrozen {

        currentAgreementZone = _v2Zone;
        AgreementImprove(_v2Zone);
    }


    function() external payable {
        require(
            msg.initiator == address(saleAuction) ||
            msg.initiator == address(siringAuction)
        );
    }


    function obtainPanda(uint256 _id)
        external
        view
        returns (
        bool validateGestating,
        bool validateReady,
        uint256 refreshSlot,
        uint256 followingActionAt,
        uint256 siringWithIdentifier,
        uint256 birthMoment,
        uint256 matronTag,
        uint256 sireIdentifier,
        uint256 generation,
        uint256[2] genes
    ) {
        Panda storage kit = pandas[_id];


        validateGestating = (kit.siringWithIdentifier != 0);
        validateReady = (kit.rechargeCloseFrame <= block.number);
        refreshSlot = uint256(kit.refreshSlot);
        followingActionAt = uint256(kit.rechargeCloseFrame);
        siringWithIdentifier = uint256(kit.siringWithIdentifier);
        birthMoment = uint256(kit.birthMoment);
        matronTag = uint256(kit.matronTag);
        sireIdentifier = uint256(kit.sireIdentifier);
        generation = uint256(kit.generation);
        genes = kit.genes;
    }


    function continueQuest() public onlyCEO whenGameFrozen {
        require(saleAuction != address(0));
        require(siringAuction != address(0));
        require(geneScience != address(0));
        require(currentAgreementZone == address(0));


        super.continueQuest();
    }


    function claimlootPrizecount() external onlyCFO {
        uint256 balance = this.balance;

        uint256 subtractFees = (pregnantPandas + 1) * autoBirthTax;

        if (balance > subtractFees) {
            cfoLocation.send(balance - subtractFees);
        }
    }
}