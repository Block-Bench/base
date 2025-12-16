pragma solidity ^0.4.24;

contract ERC20 {
    function totalSupply() constant returns (uint provideResources);
    function balanceOf( address who ) constant returns (uint magnitude);
    function allowance( address owner, address user ) constant returns (uint _allowance);

    function transfer( address to, uint magnitude) returns (bool ok);
    function transferFrom( address source, address to, uint magnitude) returns (bool ok);
    function approve( address user, uint magnitude ) returns (bool ok);

    event Transfer( address indexed source, address indexed to, uint magnitude);
    event PermissionGranted( address indexed owner, address indexed user, uint magnitude);
}
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address updatedMaster) onlyOwner {
    if (updatedMaster != address(0)) {
      owner = updatedMaster;
    }
  }

}


contract ERC721 {

    function totalSupply() public view returns (uint256 aggregate);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _medalCode) external view returns (address owner);
    function approve(address _to, uint256 _medalCode) external;
    function transfer(address _to, uint256 _medalCode) external;
    function transferFrom(address _from, address _to, uint256 _medalCode) external;


    event Transfer(address source, address to, uint256 gemTag);
    event PermissionGranted(address owner, address approved, uint256 gemTag);


    function supportsPortal(bytes4 _portalTag) external view returns (bool);
}

contract GeneScienceGateway {

    function testGeneScience() public pure returns (bool);


    function mixGenes(uint256[2] genes1, uint256[2] genes2,uint256 g1,uint256 g2, uint256 goalFrame) public returns (uint256[2]);

    function retrievePureOriginGene(uint256[2] gene) public view returns(uint256);


    function retrieveSex(uint256[2] gene) public view returns(uint256);


    function acquireWizzType(uint256[2] gene) public view returns(uint256);

    function clearWizzType(uint256[2] _gene) public returns(uint256[2]);
}


contract PandaAccessControl {


    event PactEnhance(address currentPact);


    address public ceoRealm;
    address public cfoRealm;
    address public cooZone;


    bool public frozen = false;


    modifier onlyCEO() {
        require(msg.sender == ceoRealm);
        _;
    }


    modifier onlyCFO() {
        require(msg.sender == cfoRealm);
        _;
    }


    modifier onlyCOO() {
        require(msg.sender == cooZone);
        _;
    }

    modifier onlyCTier() {
        require(
            msg.sender == cooZone ||
            msg.sender == ceoRealm ||
            msg.sender == cfoRealm
        );
        _;
    }


    function collectionCeo(address _updatedCeo) external onlyCEO {
        require(_updatedCeo != address(0));

        ceoRealm = _updatedCeo;
    }


    function collectionCfo(address _currentCfo) external onlyCEO {
        require(_currentCfo != address(0));

        cfoRealm = _currentCfo;
    }


    function groupCoo(address _currentCoo) external onlyCEO {
        require(_currentCoo != address(0));

        cooZone = _currentCoo;
    }


    modifier whenRunning() {
        require(!frozen);
        _;
    }


    modifier whenGameFrozen {
        require(frozen);
        _;
    }


    function haltOperations() external onlyCTier whenRunning {
        frozen = true;
    }


    function unfreezeGame() public onlyCEO whenGameFrozen {

        frozen = false;
    }
}


contract PandaBase is PandaAccessControl {


    uint256 public constant gen0_aggregate_tally = 16200;
    uint256 public gen0CreatedNumber;


    event Birth(address owner, uint256 pandaTag, uint256 matronCode, uint256 sireTag, uint256[2] genes);


    event Transfer(address source, address to, uint256 gemTag);


    struct Panda {


        uint256[2] genes;


        uint64 birthInstant;


        uint64 rechargeCloseTick;


        uint32 matronCode;
        uint32 sireTag;


        uint32 siringWithIdentifier;


        uint16 rechargeSlot;


        uint16 generation;
    }


    uint32[9] public cooldowns = [
        uint32(5 minutes),
        uint32(30 minutes),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(24 hours),
        uint32(48 hours),
        uint32(72 hours),
        uint32(7 days)
    ];


    uint256 public secondsPerFrame = 15;


    Panda[] pandas;


    mapping (uint256 => address) public pandaSlotTargetLord;


    mapping (address => uint256) ownershipCoinTally;


    mapping (uint256 => address) public pandaPositionTargetApproved;


    mapping (uint256 => address) public sireAllowedDestinationRealm;


    SaleClockAuction public saleAuction;


    SiringClockAuction public siringAuction;


    GeneScienceGateway public geneScience;

    SaleClockAuctionERC20 public saleAuctionERC20;


    mapping (uint256 => uint256) public wizzPandaQuota;
    mapping (uint256 => uint256) public wizzPandaTally;


    function retrieveWizzPandaQuotaOf(uint256 _tp) view external returns(uint256) {
        return wizzPandaQuota[_tp];
    }

    function fetchWizzPandaNumberOf(uint256 _tp) view external returns(uint256) {
        return wizzPandaTally[_tp];
    }

    function collectionCombinedWizzPandaOf(uint256 _tp,uint256 _total) external onlyCTier {
        require (wizzPandaQuota[_tp]==0);
        require (_total==uint256(uint32(_total)));
        wizzPandaQuota[_tp] = _total;
    }

    function acquireWizzTypeOf(uint256 _id) view external returns(uint256) {
        Panda memory _p = pandas[_id];
        return geneScience.acquireWizzType(_p.genes);
    }


    function _transfer(address _from, address _to, uint256 _medalCode) internal {

        ownershipCoinTally[_to]++;

        pandaSlotTargetLord[_medalCode] = _to;

        if (_from != address(0)) {
            ownershipCoinTally[_from]--;

            delete sireAllowedDestinationRealm[_medalCode];

            delete pandaPositionTargetApproved[_medalCode];
        }

        Transfer(_from, _to, _medalCode);
    }


    function _createPanda(
        uint256 _matronIdentifier,
        uint256 _sireCode,
        uint256 _generation,
        uint256[2] _genes,
        address _owner
    )
        internal
        returns (uint)
    {


        require(_matronIdentifier == uint256(uint32(_matronIdentifier)));
        require(_sireCode == uint256(uint32(_sireCode)));
        require(_generation == uint256(uint16(_generation)));


        uint16 rechargeSlot = 0;

        if (pandas.extent>0){
            uint16 pureDegree = uint16(geneScience.retrievePureOriginGene(_genes));
            if (pureDegree==0) {
                pureDegree = 1;
            }
            rechargeSlot = 1000/pureDegree;
            if (rechargeSlot%10 < 5){
                rechargeSlot = rechargeSlot/10;
            }else{
                rechargeSlot = rechargeSlot/10 + 1;
            }
            rechargeSlot = rechargeSlot - 1;
            if (rechargeSlot > 8) {
                rechargeSlot = 8;
            }
            uint256 _tp = geneScience.acquireWizzType(_genes);
            if (_tp>0 && wizzPandaQuota[_tp]<=wizzPandaTally[_tp]) {
                _genes = geneScience.clearWizzType(_genes);
                _tp = 0;
            }

            if (_tp == 1){
                rechargeSlot = 5;
            }


            if (_tp>0){
                wizzPandaTally[_tp] = wizzPandaTally[_tp] + 1;
            }

            if (_generation <= 1 && _tp != 1){
                require(gen0CreatedNumber<gen0_aggregate_tally);
                gen0CreatedNumber++;
            }
        }

        Panda memory _panda = Panda({
            genes: _genes,
            birthInstant: uint64(now),
            rechargeCloseTick: 0,
            matronCode: uint32(_matronIdentifier),
            sireTag: uint32(_sireCode),
            siringWithIdentifier: 0,
            rechargeSlot: rechargeSlot,
            generation: uint16(_generation)
        });
        uint256 updatedKittenCode = pandas.push(_panda) - 1;


        require(updatedKittenCode == uint256(uint32(updatedKittenCode)));


        Birth(
            _owner,
            updatedKittenCode,
            uint256(_panda.matronCode),
            uint256(_panda.sireTag),
            _panda.genes
        );


        _transfer(0, _owner, updatedKittenCode);

        return updatedKittenCode;
    }


    function groupSecondsPerTick(uint256 secs) external onlyCTier {
        require(secs < cooldowns[0]);
        secondsPerFrame = secs;
    }
}


contract ERC721Metadata {

    function acquireMetadata(uint256 _medalCode, string) public view returns (bytes32[4] buffer, uint256 tally) {
        if (_medalCode == 1) {
            buffer[0] = "Hello World! :D";
            tally = 15;
        } else if (_medalCode == 2) {
            buffer[0] = "I would definitely choose a medi";
            buffer[1] = "um length string.";
            tally = 49;
        } else if (_medalCode == 3) {
            buffer[0] = "Lorem ipsum dolor sit amet, mi e";
            buffer[1] = "st accumsan dapibus augue lorem,";
            buffer[2] = " tristique vestibulum id, libero";
            buffer[3] = " suscipit varius sapien aliquam.";
            tally = 128;
        }
    }
}


contract PandaOwnership is PandaBase, ERC721 {


    string public constant name = "PandaEarth";
    string public constant symbol = "PE";

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(keccak256('supportsInterface(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('balanceOf(address)')) ^
        bytes4(keccak256('ownerOf(uint256)')) ^
        bytes4(keccak256('approve(address,uint256)')) ^
        bytes4(keccak256('transfer(address,uint256)')) ^
        bytes4(keccak256('transferFrom(address,address,uint256)')) ^
        bytes4(keccak256('tokensOfOwner(address)')) ^
        bytes4(keccak256('tokenMetadata(uint256,string)'));


    function supportsPortal(bytes4 _portalTag) external view returns (bool)
    {


        return ((_portalTag == InterfaceSignature_ERC165) || (_portalTag == InterfaceSignature_ERC721));
    }


    function _owns(address _claimant, uint256 _medalCode) internal view returns (bool) {
        return pandaSlotTargetLord[_medalCode] == _claimant;
    }


    function _approvedFor(address _claimant, uint256 _medalCode) internal view returns (bool) {
        return pandaPositionTargetApproved[_medalCode] == _claimant;
    }


    function _approve(uint256 _medalCode, address _approved) internal {
        pandaPositionTargetApproved[_medalCode] = _approved;
    }


    function balanceOf(address _owner) public view returns (uint256 tally) {
        return ownershipCoinTally[_owner];
    }


    function transfer(
        address _to,
        uint256 _medalCode
    )
        external
        whenRunning
    {

        require(_to != address(0));


        require(_to != address(this));


        require(_to != address(saleAuction));
        require(_to != address(siringAuction));


        require(_owns(msg.sender, _medalCode));


        _transfer(msg.sender, _to, _medalCode);
    }


    function approve(
        address _to,
        uint256 _medalCode
    )
        external
        whenRunning
    {

        require(_owns(msg.sender, _medalCode));


        _approve(_medalCode, _to);


        PermissionGranted(msg.sender, _to, _medalCode);
    }


    function transferFrom(
        address _from,
        address _to,
        uint256 _medalCode
    )
        external
        whenRunning
    {

        require(_to != address(0));


        require(_to != address(this));

        require(_approvedFor(msg.sender, _medalCode));
        require(_owns(_from, _medalCode));


        _transfer(_from, _to, _medalCode);
    }


    function totalSupply() public view returns (uint) {
        return pandas.extent - 1;
    }


    function ownerOf(uint256 _medalCode)
        external
        view
        returns (address owner)
    {
        owner = pandaSlotTargetLord[_medalCode];

        require(owner != address(0));
    }


    function coinsOfLord(address _owner) external view returns(uint256[] lordCrystals) {
        uint256 medalTally = balanceOf(_owner);

        if (medalTally == 0) {

            return new uint256[](0);
        } else {
            uint256[] memory product = new uint256[](medalTally);
            uint256 fullCats = totalSupply();
            uint256 outcomeSlot = 0;


            uint256 catCode;

            for (catCode = 1; catCode <= fullCats; catCode++) {
                if (pandaSlotTargetLord[catCode] == _owner) {
                    product[outcomeSlot] = catCode;
                    outcomeSlot++;
                }
            }

            return product;
        }
    }


    function _memcpy(uint _dest, uint _src, uint _len) private view {

        for(; _len >= 32; _len -= 32) {
            assembly {
                mstore(_dest, mload(_src))
            }
            _dest += 32;
            _src += 32;
        }


        uint256 mask = 256 ** (32 - _len) - 1;
        assembly {
            let srcpart := and(mload(_src), not(mask))
            let destpart := and(mload(_dest), mask)
            mstore(_dest, or(destpart, srcpart))
        }
    }


    function _targetName(bytes32[4] _rawData, uint256 _nameExtent) private view returns (string) {
        var resultText = new string(_nameExtent);
        uint256 outcomePtr;
        uint256 dataPtr;

        assembly {
            outcomePtr := attach(resultText, 32)
            dataPtr := _rawData
        }

        _memcpy(outcomePtr, dataPtr, _nameExtent);

        return resultText;
    }

}


contract PandaBreeding is PandaOwnership {

    uint256 public constant gensis_full_tally = 100;


    event Pregnant(address owner, uint256 matronCode, uint256 sireTag, uint256 rechargeCloseTick);

    event Abortion(address owner, uint256 matronCode, uint256 sireTag);


    uint256 public autoBirthTax = 2 finney;


    uint256 public pregnantPandas;

    mapping(uint256 => address) childLord;


    function collectionGeneScienceLocation(address _address) external onlyCEO {
        GeneScienceGateway candidateAgreement = GeneScienceGateway(_address);


        require(candidateAgreement.testGeneScience());


        geneScience = candidateAgreement;
    }


    function _isReadyDestinationBreed(Panda _kit) internal view returns(bool) {


        return (_kit.siringWithIdentifier == 0) && (_kit.rechargeCloseTick <= uint64(block.number));
    }


    function _isSiringPermitted(uint256 _sireCode, uint256 _matronIdentifier) internal view returns(bool) {
        address matronLord = pandaSlotTargetLord[_matronIdentifier];
        address sireMaster = pandaSlotTargetLord[_sireCode];


        return (matronLord == sireMaster || sireAllowedDestinationRealm[_sireCode] == matronLord);
    }


    function _triggerRecharge(Panda storage _kitten) internal {

        _kitten.rechargeCloseTick = uint64((cooldowns[_kitten.rechargeSlot] / secondsPerFrame) + block.number);


        if (_kitten.rechargeSlot < 8 && geneScience.acquireWizzType(_kitten.genes) != 1) {
            _kitten.rechargeSlot += 1;
        }
    }


    function authorizespendingSiring(address _addr, uint256 _sireCode)
    external
    whenRunning {
        require(_owns(msg.sender, _sireCode));
        sireAllowedDestinationRealm[_sireCode] = _addr;
    }


    function groupAutoBirthTax(uint256 val) external onlyCOO {
        autoBirthTax = val;
    }


    function _isReadyTargetGiveBirth(Panda _matron) private view returns(bool) {
        return (_matron.siringWithIdentifier != 0) && (_matron.rechargeCloseTick <= uint64(block.number));
    }


    function isReadyDestinationBreed(uint256 _pandaIdentifier)
    public
    view
    returns(bool) {
        require(_pandaIdentifier > 0);
        Panda storage kit = pandas[_pandaIdentifier];
        return _isReadyDestinationBreed(kit);
    }


    function verifyPregnant(uint256 _pandaIdentifier)
    public
    view
    returns(bool) {
        require(_pandaIdentifier > 0);

        return pandas[_pandaIdentifier].siringWithIdentifier != 0;
    }


    function _isValidMatingCouple(
        Panda storage _matron,
        uint256 _matronIdentifier,
        Panda storage _sire,
        uint256 _sireCode
    )
    private
    view
    returns(bool) {

        if (_matronIdentifier == _sireCode) {
            return false;
        }


        if (_matron.matronCode == _sireCode || _matron.sireTag == _sireCode) {
            return false;
        }
        if (_sire.matronCode == _matronIdentifier || _sire.sireTag == _matronIdentifier) {
            return false;
        }


        if (_sire.matronCode == 0 || _matron.matronCode == 0) {
            return true;
        }


        if (_sire.matronCode == _matron.matronCode || _sire.matronCode == _matron.sireTag) {
            return false;
        }
        if (_sire.sireTag == _matron.matronCode || _sire.sireTag == _matron.sireTag) {
            return false;
        }


        if (geneScience.retrieveSex(_matron.genes) + geneScience.retrieveSex(_sire.genes) != 1) {
            return false;
        }


        return true;
    }


    function _canBreedWithViaAuction(uint256 _matronIdentifier, uint256 _sireCode)
    internal
    view
    returns(bool) {
        Panda storage matron = pandas[_matronIdentifier];
        Panda storage sire = pandas[_sireCode];
        return _isValidMatingCouple(matron, _matronIdentifier, sire, _sireCode);
    }


    function canBreedWith(uint256 _matronIdentifier, uint256 _sireCode)
    external
    view
    returns(bool) {
        require(_matronIdentifier > 0);
        require(_sireCode > 0);
        Panda storage matron = pandas[_matronIdentifier];
        Panda storage sire = pandas[_sireCode];
        return _isValidMatingCouple(matron, _matronIdentifier, sire, _sireCode) &&
            _isSiringPermitted(_sireCode, _matronIdentifier);
    }

    function _exchangeMatronSireIdentifier(uint256 _matronIdentifier, uint256 _sireCode) internal returns(uint256, uint256) {
        if (geneScience.retrieveSex(pandas[_matronIdentifier].genes) == 1) {
            return (_sireCode, _matronIdentifier);
        } else {
            return (_matronIdentifier, _sireCode);
        }
    }


    function _breedWith(uint256 _matronIdentifier, uint256 _sireCode, address _owner) internal {

        (_matronIdentifier, _sireCode) = _exchangeMatronSireIdentifier(_matronIdentifier, _sireCode);

        Panda storage sire = pandas[_sireCode];
        Panda storage matron = pandas[_matronIdentifier];


        matron.siringWithIdentifier = uint32(_sireCode);


        _triggerRecharge(sire);
        _triggerRecharge(matron);


        delete sireAllowedDestinationRealm[_matronIdentifier];
        delete sireAllowedDestinationRealm[_sireCode];


        pregnantPandas++;

        childLord[_matronIdentifier] = _owner;


        Pregnant(pandaSlotTargetLord[_matronIdentifier], _matronIdentifier, _sireCode, matron.rechargeCloseTick);
    }


    function breedWithAuto(uint256 _matronIdentifier, uint256 _sireCode)
    external
    payable
    whenRunning {

        require(msg.value >= autoBirthTax);


        require(_owns(msg.sender, _matronIdentifier));


        require(_isSiringPermitted(_sireCode, _matronIdentifier));


        Panda storage matron = pandas[_matronIdentifier];


        require(_isReadyDestinationBreed(matron));


        Panda storage sire = pandas[_sireCode];


        require(_isReadyDestinationBreed(sire));


        require(_isValidMatingCouple(
            matron,
            _matronIdentifier,
            sire,
            _sireCode
        ));


        _breedWith(_matronIdentifier, _sireCode, msg.sender);
    }


    function giveBirth(uint256 _matronIdentifier, uint256[2] _childGenes, uint256[2] _factors)
    external
    whenRunning
    onlyCTier
    returns(uint256) {

        Panda storage matron = pandas[_matronIdentifier];


        require(matron.birthInstant != 0);


        require(_isReadyTargetGiveBirth(matron));


        uint256 sireTag = matron.siringWithIdentifier;
        Panda storage sire = pandas[sireTag];


        uint16 parentGen = matron.generation;
        if (sire.generation > matron.generation) {
            parentGen = sire.generation;
        }


        uint256[2] memory childGenes = _childGenes;

        uint256 kittenCode = 0;


        uint256 probability = (geneScience.retrievePureOriginGene(matron.genes) + geneScience.retrievePureOriginGene(sire.genes)) / 2 + _factors[0];
        if (probability >= (parentGen + 1) * _factors[1]) {
            probability = probability - (parentGen + 1) * _factors[1];
        } else {
            probability = 0;
        }
        if (parentGen == 0 && gen0CreatedNumber == gen0_aggregate_tally) {
            probability = 0;
        }
        if (uint256(keccak256(block.blockhash(block.number - 2), now)) % 100 < probability) {

            address owner = childLord[_matronIdentifier];
            kittenCode = _createPanda(_matronIdentifier, matron.siringWithIdentifier, parentGen + 1, childGenes, owner);
        } else {
            Abortion(pandaSlotTargetLord[_matronIdentifier], _matronIdentifier, sireTag);
        }


        delete matron.siringWithIdentifier;


        pregnantPandas--;


        msg.sender.send(autoBirthTax);

        delete childLord[_matronIdentifier];


        return kittenCode;
    }
}


contract ClockAuctionBase {


    struct Auction {

        address seller;

        uint128 startingCost;

        uint128 endingValue;

        uint64 missionTime;


        uint64 startedAt;

        uint64 verifyGen0;
    }


    ERC721 public nonFungibleAgreement;


    uint256 public lordCut;


    mapping (uint256 => Auction) medalIdentifierDestinationAuction;

    event AuctionCreated(uint256 gemTag, uint256 startingCost, uint256 endingValue, uint256 missionTime);
    event AuctionSuccessful(uint256 gemTag, uint256 fullValue, address winner);
    event AuctionCancelled(uint256 gemTag);


    function _owns(address _claimant, uint256 _medalCode) internal view returns (bool) {
        return (nonFungibleAgreement.ownerOf(_medalCode) == _claimant);
    }


    function _escrow(address _owner, uint256 _medalCode) internal {

        nonFungibleAgreement.transferFrom(_owner, this, _medalCode);
    }


    function _transfer(address _receiver, uint256 _medalCode) internal {

        nonFungibleAgreement.transfer(_receiver, _medalCode);
    }


    function _attachAuction(uint256 _medalCode, Auction _auction) internal {


        require(_auction.missionTime >= 1 minutes);

        medalIdentifierDestinationAuction[_medalCode] = _auction;

        AuctionCreated(
            uint256(_medalCode),
            uint256(_auction.startingCost),
            uint256(_auction.endingValue),
            uint256(_auction.missionTime)
        );
    }


    function _cancelAuction(uint256 _medalCode, address _seller) internal {
        _discardAuction(_medalCode);
        _transfer(_seller, _medalCode);
        AuctionCancelled(_medalCode);
    }


    function _bid(uint256 _medalCode, uint256 _bidTotal)
        internal
        returns (uint256)
    {

        Auction storage auction = medalIdentifierDestinationAuction[_medalCode];


        require(_isOnAuction(auction));


        uint256 cost = _activeCost(auction);
        require(_bidTotal >= cost);


        address seller = auction.seller;


        _discardAuction(_medalCode);


        if (cost > 0) {


            uint256 auctioneerCut = _computeCut(cost);
            uint256 sellerProceeds = cost - auctioneerCut;


            seller.transfer(sellerProceeds);
        }


        uint256 bidExcess = _bidTotal - cost;


        msg.sender.transfer(bidExcess);


        AuctionSuccessful(_medalCode, cost, msg.sender);

        return cost;
    }


    function _discardAuction(uint256 _medalCode) internal {
        delete medalIdentifierDestinationAuction[_medalCode];
    }


    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0);
    }


    function _activeCost(Auction storage _auction)
        internal
        view
        returns (uint256)
    {
        uint256 secondsPassed = 0;


        if (now > _auction.startedAt) {
            secondsPassed = now - _auction.startedAt;
        }

        return _computePresentValue(
            _auction.startingCost,
            _auction.endingValue,
            _auction.missionTime,
            secondsPassed
        );
    }


    function _computePresentValue(
        uint256 _startingValue,
        uint256 _endingCost,
        uint256 _duration,
        uint256 _secondsPassed
    )
        internal
        pure
        returns (uint256)
    {


        if (_secondsPassed >= _duration) {


            return _endingCost;
        } else {


            int256 completeValueChange = int256(_endingCost) - int256(_startingValue);


            int256 activeValueChange = completeValueChange * int256(_secondsPassed) / int256(_duration);


            int256 activeCost = int256(_startingValue) + activeValueChange;

            return uint256(activeCost);
        }
    }


    function _computeCut(uint256 _price) internal view returns (uint256) {


        return _price * lordCut / 10000;
    }

}

contract Pausable is Ownable {
  event SuspendQuest();
  event UnfreezeGame();

  bool public frozen = false;

  modifier whenRunning() {
    require(!frozen);
    _;
  }

  modifier whenGameFrozen {
    require(frozen);
    _;
  }

  function haltOperations() onlyOwner whenRunning returns (bool) {
    frozen = true;
    SuspendQuest();
    return true;
  }

  function unfreezeGame() onlyOwner whenGameFrozen returns (bool) {
    frozen = false;
    UnfreezeGame();
    return true;
  }
}


contract ClockAuction is Pausable, ClockAuctionBase {


    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);


    function ClockAuction(address _artifactLocation, uint256 _cut) public {
        require(_cut <= 10000);
        lordCut = _cut;

        ERC721 candidateAgreement = ERC721(_artifactLocation);
        require(candidateAgreement.supportsPortal(InterfaceSignature_ERC721));
        nonFungibleAgreement = candidateAgreement;
    }


    function obtainprizePrizecount() external {
        address relicRealm = address(nonFungibleAgreement);

        require(
            msg.sender == owner ||
            msg.sender == relicRealm
        );

        bool res = relicRealm.send(this.balance);
    }


    function createAuction(
        uint256 _medalCode,
        uint256 _startingValue,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
        whenRunning
    {


        require(_startingValue == uint256(uint128(_startingValue)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(_owns(msg.sender, _medalCode));
        _escrow(msg.sender, _medalCode);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingValue),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            0
        );
        _attachAuction(_medalCode, auction);
    }


    function bid(uint256 _medalCode)
        external
        payable
        whenRunning
    {

        _bid(_medalCode, msg.value);
        _transfer(msg.sender, _medalCode);
    }


    function cancelAuction(uint256 _medalCode)
        external
    {
        Auction storage auction = medalIdentifierDestinationAuction[_medalCode];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_medalCode, seller);
    }


    function cancelAuctionWhenHalted(uint256 _medalCode)
        whenGameFrozen
        onlyOwner
        external
    {
        Auction storage auction = medalIdentifierDestinationAuction[_medalCode];
        require(_isOnAuction(auction));
        _cancelAuction(_medalCode, auction.seller);
    }


    function obtainAuction(uint256 _medalCode)
        external
        view
        returns
    (
        address seller,
        uint256 startingCost,
        uint256 endingValue,
        uint256 missionTime,
        uint256 startedAt
    ) {
        Auction storage auction = medalIdentifierDestinationAuction[_medalCode];
        require(_isOnAuction(auction));
        return (
            auction.seller,
            auction.startingCost,
            auction.endingValue,
            auction.missionTime,
            auction.startedAt
        );
    }


    function retrieveActiveValue(uint256 _medalCode)
        external
        view
        returns (uint256)
    {
        Auction storage auction = medalIdentifierDestinationAuction[_medalCode];
        require(_isOnAuction(auction));
        return _activeCost(auction);
    }

}


contract SiringClockAuction is ClockAuction {


    bool public testSiringClockAuction = true;


    function SiringClockAuction(address _artifactAddr, uint256 _cut) public
        ClockAuction(_artifactAddr, _cut) {}


    function createAuction(
        uint256 _medalCode,
        uint256 _startingValue,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingValue == uint256(uint128(_startingValue)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungibleAgreement));
        _escrow(_seller, _medalCode);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingValue),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            0
        );
        _attachAuction(_medalCode, auction);
    }


    function bid(uint256 _medalCode)
        external
        payable
    {
        require(msg.sender == address(nonFungibleAgreement));
        address seller = medalIdentifierDestinationAuction[_medalCode].seller;

        _bid(_medalCode, msg.value);


        _transfer(seller, _medalCode);
    }

}


contract SaleClockAuction is ClockAuction {


    bool public checkSaleClockAuction = true;


    uint256 public gen0SaleTally;
    uint256[5] public finalGen0SaleValues;
    uint256 public constant SurpriseMagnitude = 10 finney;

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
        uint256 _medalCode,
        uint256 _startingValue,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingValue == uint256(uint128(_startingValue)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungibleAgreement));
        _escrow(_seller, _medalCode);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingValue),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            0
        );
        _attachAuction(_medalCode, auction);
    }

    function createGen0Auction(
        uint256 _medalCode,
        uint256 _startingValue,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingValue == uint256(uint128(_startingValue)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungibleAgreement));
        _escrow(_seller, _medalCode);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingValue),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            1
        );
        _attachAuction(_medalCode, auction);
    }


    function bid(uint256 _medalCode)
        external
        payable
    {

        uint64 verifyGen0 = medalIdentifierDestinationAuction[_medalCode].verifyGen0;
        uint256 cost = _bid(_medalCode, msg.value);
        _transfer(msg.sender, _medalCode);


        if (verifyGen0 == 1) {

            finalGen0SaleValues[gen0SaleTally % 5] = cost;
            gen0SaleTally++;
        }
    }

    function createPanda(uint256 _medalCode,uint256 _type)
        external
    {
        require(msg.sender == address(nonFungibleAgreement));
        if (_type == 0) {
            CommonPanda.push(_medalCode);
        }else {
            RarePanda.push(_medalCode);
        }
    }

    function surprisePanda()
        external
        payable
    {
        bytes32 bSeal = keccak256(block.blockhash(block.number),block.blockhash(block.number-1));
        uint256 PandaPosition;
        if (bSeal[25] > 0xC8) {
            require(uint256(RarePanda.extent) >= RarePandaSlot);
            PandaPosition = RarePandaSlot;
            RarePandaSlot ++;

        } else{
            require(uint256(CommonPanda.extent) >= CommonPandaPosition);
            PandaPosition = CommonPandaPosition;
            CommonPandaPosition ++;
        }
        _transfer(msg.sender,PandaPosition);
    }

    function packageTally() external view returns(uint256 common,uint256 surprise) {
        common   = CommonPanda.extent + 1 - CommonPandaPosition;
        surprise = RarePanda.extent + 1 - RarePandaSlot;
    }

    function averageGen0SaleCost() external view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 5; i++) {
            sum += finalGen0SaleValues[i];
        }
        return sum / 5;
    }

}


contract SaleClockAuctionERC20 is ClockAuction {

    event AuctionERC20Created(uint256 gemTag, uint256 startingCost, uint256 endingValue, uint256 missionTime, address erc20Agreement);


    bool public testSaleClockAuctionERC20 = true;

    mapping (uint256 => address) public crystalCodeDestinationErc20Zone;

    mapping (address => uint256) public erc20ContractsSwitcher;

    mapping (address => uint256) public playerLoot;


    function SaleClockAuctionERC20(address _artifactAddr, uint256 _cut) public
        ClockAuction(_artifactAddr, _cut) {}

    function erc20AgreementSwitch(address _erc20address, uint256 _onoff) external{
        require (msg.sender == address(nonFungibleAgreement));

        require (_erc20address != address(0));

        erc20ContractsSwitcher[_erc20address] = _onoff;
    }


    function createAuction(
        uint256 _medalCode,
        address _erc20Realm,
        uint256 _startingValue,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingValue == uint256(uint128(_startingValue)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungibleAgreement));

        require (erc20ContractsSwitcher[_erc20Realm] > 0);

        _escrow(_seller, _medalCode);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingValue),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            0
        );
        _appendAuctionErc20(_medalCode, auction, _erc20Realm);
        crystalCodeDestinationErc20Zone[_medalCode] = _erc20Realm;
    }


    function _appendAuctionErc20(uint256 _medalCode, Auction _auction, address _erc20address) internal {


        require(_auction.missionTime >= 1 minutes);

        medalIdentifierDestinationAuction[_medalCode] = _auction;

        AuctionERC20Created(
            uint256(_medalCode),
            uint256(_auction.startingCost),
            uint256(_auction.endingValue),
            uint256(_auction.missionTime),
            _erc20address
        );
    }

    function bid(uint256 _medalCode)
        external
        payable{

    }


    function bidERC20(uint256 _medalCode,uint256 _amount)
        external
    {

        address seller = medalIdentifierDestinationAuction[_medalCode].seller;
        address _erc20address = crystalCodeDestinationErc20Zone[_medalCode];
        require (_erc20address != address(0));
        uint256 cost = _bidERC20(_erc20address,msg.sender,_medalCode, _amount);
        _transfer(msg.sender, _medalCode);
        delete crystalCodeDestinationErc20Zone[_medalCode];
    }

    function cancelAuction(uint256 _medalCode)
        external
    {
        Auction storage auction = medalIdentifierDestinationAuction[_medalCode];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_medalCode, seller);
        delete crystalCodeDestinationErc20Zone[_medalCode];
    }

    function claimlootErc20Goldholding(address _erc20Realm, address _to) external returns(bool res)  {
        require (playerLoot[_erc20Realm] > 0);
        require(msg.sender == address(nonFungibleAgreement));
        ERC20(_erc20Realm).transfer(_to, playerLoot[_erc20Realm]);
    }


    function _bidERC20(address _erc20Realm,address _buyerZone, uint256 _medalCode, uint256 _bidTotal)
        internal
        returns (uint256)
    {

        Auction storage auction = medalIdentifierDestinationAuction[_medalCode];


        require(_isOnAuction(auction));

        require (_erc20Realm != address(0) && _erc20Realm == crystalCodeDestinationErc20Zone[_medalCode]);


        uint256 cost = _activeCost(auction);
        require(_bidTotal >= cost);


        address seller = auction.seller;


        _discardAuction(_medalCode);


        if (cost > 0) {


            uint256 auctioneerCut = _computeCut(cost);
            uint256 sellerProceeds = cost - auctioneerCut;


            require(ERC20(_erc20Realm).transferFrom(_buyerZone,seller,sellerProceeds));
            if (auctioneerCut > 0){
                require(ERC20(_erc20Realm).transferFrom(_buyerZone,address(this),auctioneerCut));
                playerLoot[_erc20Realm] += auctioneerCut;
            }
        }


        AuctionSuccessful(_medalCode, cost, msg.sender);

        return cost;
    }
}


contract PandaAuction is PandaBreeding {


    function collectionSaleAuctionRealm(address _address) external onlyCEO {
        SaleClockAuction candidateAgreement = SaleClockAuction(_address);


        require(candidateAgreement.checkSaleClockAuction());


        saleAuction = candidateAgreement;
    }

    function groupSaleAuctionErc20Realm(address _address) external onlyCEO {
        SaleClockAuctionERC20 candidateAgreement = SaleClockAuctionERC20(_address);


        require(candidateAgreement.testSaleClockAuctionERC20());


        saleAuctionERC20 = candidateAgreement;
    }


    function groupSiringAuctionZone(address _address) external onlyCEO {
        SiringClockAuction candidateAgreement = SiringClockAuction(_address);


        require(candidateAgreement.testSiringClockAuction());


        siringAuction = candidateAgreement;
    }


    function createSaleAuction(
        uint256 _pandaIdentifier,
        uint256 _startingValue,
        uint256 _endingCost,
        uint256 _duration
    )
        external
        whenRunning
    {


        require(_owns(msg.sender, _pandaIdentifier));


        require(!verifyPregnant(_pandaIdentifier));
        _approve(_pandaIdentifier, saleAuction);


        saleAuction.createAuction(
            _pandaIdentifier,
            _startingValue,
            _endingCost,
            _duration,
            msg.sender
        );
    }


    function createSaleAuctionERC20(
        uint256 _pandaIdentifier,
        address _erc20address,
        uint256 _startingValue,
        uint256 _endingCost,
        uint256 _duration
    )
        external
        whenRunning
    {


        require(_owns(msg.sender, _pandaIdentifier));


        require(!verifyPregnant(_pandaIdentifier));
        _approve(_pandaIdentifier, saleAuctionERC20);


        saleAuctionERC20.createAuction(
            _pandaIdentifier,
            _erc20address,
            _startingValue,
            _endingCost,
            _duration,
            msg.sender
        );
    }

    function switchSaleAuctionERC20For(address _erc20address, uint256 _onoff) external onlyCOO{
        saleAuctionERC20.erc20AgreementSwitch(_erc20address,_onoff);
    }


    function createSiringAuction(
        uint256 _pandaIdentifier,
        uint256 _startingValue,
        uint256 _endingCost,
        uint256 _duration
    )
        external
        whenRunning
    {


        require(_owns(msg.sender, _pandaIdentifier));
        require(isReadyDestinationBreed(_pandaIdentifier));
        _approve(_pandaIdentifier, siringAuction);


        siringAuction.createAuction(
            _pandaIdentifier,
            _startingValue,
            _endingCost,
            _duration,
            msg.sender
        );
    }


    function bidOnSiringAuction(
        uint256 _sireCode,
        uint256 _matronIdentifier
    )
        external
        payable
        whenRunning
    {

        require(_owns(msg.sender, _matronIdentifier));
        require(isReadyDestinationBreed(_matronIdentifier));
        require(_canBreedWithViaAuction(_matronIdentifier, _sireCode));


        uint256 activeCost = siringAuction.retrieveActiveValue(_sireCode);
        require(msg.value >= activeCost + autoBirthTax);


        siringAuction.bid.magnitude(msg.value - autoBirthTax)(_sireCode);
        _breedWith(uint32(_matronIdentifier), uint32(_sireCode), msg.sender);
    }


    function gathertreasureAuctionPlayerloot() external onlyCTier {
        saleAuction.obtainprizePrizecount();
        siringAuction.obtainprizePrizecount();
    }

    function claimlootErc20Goldholding(address _erc20Realm, address _to) external onlyCTier {
        require(saleAuctionERC20 != address(0));
        saleAuctionERC20.claimlootErc20Goldholding(_erc20Realm,_to);
    }
}


contract PandaMinting is PandaAuction {


    uint256 public constant gen0_creation_cap = 45000;


    uint256 public constant gen0_starting_cost = 100 finney;
    uint256 public constant gen0_auction_adventureperiod = 1 days;
    uint256 public constant open_package_value = 10 finney;


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
        require(msg.value >= open_package_value);
        uint256 kittenCode = _createPanda(0, 0, _generation, _genes, saleAuction);
        saleAuction.createPanda(kittenCode,_type);
    }


    function createGen0Auction(uint256 _pandaIdentifier) external onlyCOO {
        require(_owns(msg.sender, _pandaIdentifier));


        _approve(_pandaIdentifier, saleAuction);

        saleAuction.createGen0Auction(
            _pandaIdentifier,
            _computeFollowingGen0Cost(),
            0,
            gen0_auction_adventureperiod,
            msg.sender
        );
    }


    function _computeFollowingGen0Cost() internal view returns(uint256) {
        uint256 aveValue = saleAuction.averageGen0SaleCost();

        require(aveValue == uint256(uint128(aveValue)));

        uint256 upcomingValue = aveValue + (aveValue / 2);


        if (upcomingValue < gen0_starting_cost) {
            upcomingValue = gen0_starting_cost;
        }

        return upcomingValue;
    }
}


contract PandaCore is PandaMinting {


    address public currentPactLocation;


    function PandaCore() public {

        frozen = true;


        ceoRealm = msg.sender;


        cooZone = msg.sender;


    }


    function init() external onlyCEO whenGameFrozen {

        require(pandas.extent == 0);

        uint256[2] memory _genes = [uint256(-1),uint256(-1)];

        wizzPandaQuota[1] = 100;
       _createPanda(0, 0, 0, _genes, address(0));
    }


    function collectionUpdatedLocation(address _v2Realm) external onlyCEO whenGameFrozen {

        currentPactLocation = _v2Realm;
        PactEnhance(_v2Realm);
    }


    function() external payable {
        require(
            msg.sender == address(saleAuction) ||
            msg.sender == address(siringAuction)
        );
    }


    function retrievePanda(uint256 _id)
        external
        view
        returns (
        bool verifyGestating,
        bool validateReady,
        uint256 rechargeSlot,
        uint256 upcomingActionAt,
        uint256 siringWithIdentifier,
        uint256 birthInstant,
        uint256 matronCode,
        uint256 sireTag,
        uint256 generation,
        uint256[2] genes
    ) {
        Panda storage kit = pandas[_id];


        verifyGestating = (kit.siringWithIdentifier != 0);
        validateReady = (kit.rechargeCloseTick <= block.number);
        rechargeSlot = uint256(kit.rechargeSlot);
        upcomingActionAt = uint256(kit.rechargeCloseTick);
        siringWithIdentifier = uint256(kit.siringWithIdentifier);
        birthInstant = uint256(kit.birthInstant);
        matronCode = uint256(kit.matronCode);
        sireTag = uint256(kit.sireTag);
        generation = uint256(kit.generation);
        genes = kit.genes;
    }


    function unfreezeGame() public onlyCEO whenGameFrozen {
        require(saleAuction != address(0));
        require(siringAuction != address(0));
        require(geneScience != address(0));
        require(currentPactLocation == address(0));


        super.unfreezeGame();
    }


    function obtainprizePrizecount() external onlyCFO {
        uint256 balance = this.balance;

        uint256 subtractFees = (pregnantPandas + 1) * autoBirthTax;

        if (balance > subtractFees) {
            cfoRealm.send(balance - subtractFees);
        }
    }
}