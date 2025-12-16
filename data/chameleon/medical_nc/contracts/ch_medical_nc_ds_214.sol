pragma solidity ^0.4.24;

contract ERC20 {
    function totalSupply() constant returns (uint provideResources);
    function balanceOf( address who ) constant returns (uint assessment);
    function allowance( address owner, address payer ) constant returns (uint _allowance);

    function transfer( address to, uint assessment) returns (bool ok);
    function transferFrom( address source, address to, uint assessment) returns (bool ok);
    function approve( address payer, uint assessment ) returns (bool ok);

    event Transfer( address indexed source, address indexed to, uint assessment);
    event TreatmentAuthorized( address indexed owner, address indexed payer, uint assessment);
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

  function transferOwnership(address updatedDirector) onlyOwner {
    if (updatedDirector != address(0)) {
      owner = updatedDirector;
    }
  }

}


contract ERC721 {

    function totalSupply() public view returns (uint256 cumulative);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _credentialCasenumber) external view returns (address owner);
    function approve(address _to, uint256 _credentialCasenumber) external;
    function transfer(address _to, uint256 _credentialCasenumber) external;
    function transferFrom(address _from, address _to, uint256 _credentialCasenumber) external;


    event Transfer(address source, address to, uint256 badgeIdentifier);
    event TreatmentAuthorized(address owner, address approved, uint256 badgeIdentifier);


    function supportsPortal(bytes4 _portalChartnumber) external view returns (bool);
}

contract GeneScienceGateway {

    function checkGeneScience() public pure returns (bool);


    function mixGenes(uint256[2] genes1, uint256[2] genes2,uint256 g1,uint256 g2, uint256 goalWard) public returns (uint256[2]);

    function diagnosePureReferrerGene(uint256[2] gene) public view returns(uint256);


    function retrieveSex(uint256[2] gene) public view returns(uint256);


    function diagnoseWizzType(uint256[2] gene) public view returns(uint256);

    function clearWizzType(uint256[2] _gene) public returns(uint256[2]);
}


contract PandaAccessControl {


    event PolicyImprove(address currentPolicy);


    address public ceoFacility;
    address public cfoLocation;
    address public cooLocation;


    bool public suspended = false;


    modifier onlyCEO() {
        require(msg.sender == ceoFacility);
        _;
    }


    modifier onlyCFO() {
        require(msg.sender == cfoLocation);
        _;
    }


    modifier onlyCOO() {
        require(msg.sender == cooLocation);
        _;
    }

    modifier onlyCTier() {
        require(
            msg.sender == cooLocation ||
            msg.sender == ceoFacility ||
            msg.sender == cfoLocation
        );
        _;
    }


    function collectionCeo(address _updatedCeo) external onlyCEO {
        require(_updatedCeo != address(0));

        ceoFacility = _updatedCeo;
    }


    function collectionCfo(address _updatedCfo) external onlyCEO {
        require(_updatedCfo != address(0));

        cfoLocation = _updatedCfo;
    }


    function collectionCoo(address _updatedCoo) external onlyCEO {
        require(_updatedCoo != address(0));

        cooLocation = _updatedCoo;
    }


    modifier whenOperational() {
        require(!suspended);
        _;
    }


    modifier whenSuspended {
        require(suspended);
        _;
    }


    function freezeProtocol() external onlyCTier whenOperational {
        suspended = true;
    }


    function resumeTreatment() public onlyCEO whenSuspended {

        suspended = false;
    }
}


contract PandaBase is PandaAccessControl {


    uint256 public constant gen0_complete_tally = 16200;
    uint256 public gen0CreatedTally;


    event Birth(address owner, uint256 pandaIdentifier, uint256 matronCasenumber, uint256 sireIdentifier, uint256[2] genes);


    event Transfer(address source, address to, uint256 badgeIdentifier);


    struct Panda {


        uint256[2] genes;


        uint64 birthInstant;


        uint64 recoveryFinishWard;


        uint32 matronCasenumber;
        uint32 sireIdentifier;


        uint32 siringWithIdentifier;


        uint16 recoveryPosition;


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


    uint256 public secondsPerWard = 15;


    Panda[] pandas;


    mapping (uint256 => address) public pandaSlotDestinationAdministrator;


    mapping (address => uint256) ownershipCredentialTally;


    mapping (uint256 => address) public pandaPositionReceiverApproved;


    mapping (uint256 => address) public sireAllowedReceiverWard;


    SaleClockAuction public saleAuction;


    SiringClockAuction public siringAuction;


    GeneScienceGateway public geneScience;

    SaleClockAuctionERC20 public saleAuctionERC20;


    mapping (uint256 => uint256) public wizzPandaQuota;
    mapping (uint256 => uint256) public wizzPandaTally;


    function obtainWizzPandaQuotaOf(uint256 _tp) view external returns(uint256) {
        return wizzPandaQuota[_tp];
    }

    function retrieveWizzPandaTallyOf(uint256 _tp) view external returns(uint256) {
        return wizzPandaTally[_tp];
    }

    function collectionCompleteWizzPandaOf(uint256 _tp,uint256 _total) external onlyCTier {
        require (wizzPandaQuota[_tp]==0);
        require (_total==uint256(uint32(_total)));
        wizzPandaQuota[_tp] = _total;
    }

    function acquireWizzTypeOf(uint256 _id) view external returns(uint256) {
        Panda memory _p = pandas[_id];
        return geneScience.diagnoseWizzType(_p.genes);
    }


    function _transfer(address _from, address _to, uint256 _credentialCasenumber) internal {

        ownershipCredentialTally[_to]++;

        pandaSlotDestinationAdministrator[_credentialCasenumber] = _to;

        if (_from != address(0)) {
            ownershipCredentialTally[_from]--;

            delete sireAllowedReceiverWard[_credentialCasenumber];

            delete pandaPositionReceiverApproved[_credentialCasenumber];
        }

        Transfer(_from, _to, _credentialCasenumber);
    }


    function _createPanda(
        uint256 _matronChartnumber,
        uint256 _sireChartnumber,
        uint256 _generation,
        uint256[2] _genes,
        address _owner
    )
        internal
        returns (uint)
    {


        require(_matronChartnumber == uint256(uint32(_matronChartnumber)));
        require(_sireChartnumber == uint256(uint32(_sireChartnumber)));
        require(_generation == uint256(uint16(_generation)));


        uint16 recoveryPosition = 0;

        if (pandas.extent>0){
            uint16 pureDegree = uint16(geneScience.diagnosePureReferrerGene(_genes));
            if (pureDegree==0) {
                pureDegree = 1;
            }
            recoveryPosition = 1000/pureDegree;
            if (recoveryPosition%10 < 5){
                recoveryPosition = recoveryPosition/10;
            }else{
                recoveryPosition = recoveryPosition/10 + 1;
            }
            recoveryPosition = recoveryPosition - 1;
            if (recoveryPosition > 8) {
                recoveryPosition = 8;
            }
            uint256 _tp = geneScience.diagnoseWizzType(_genes);
            if (_tp>0 && wizzPandaQuota[_tp]<=wizzPandaTally[_tp]) {
                _genes = geneScience.clearWizzType(_genes);
                _tp = 0;
            }

            if (_tp == 1){
                recoveryPosition = 5;
            }


            if (_tp>0){
                wizzPandaTally[_tp] = wizzPandaTally[_tp] + 1;
            }

            if (_generation <= 1 && _tp != 1){
                require(gen0CreatedTally<gen0_complete_tally);
                gen0CreatedTally++;
            }
        }

        Panda memory _panda = Panda({
            genes: _genes,
            birthInstant: uint64(now),
            recoveryFinishWard: 0,
            matronCasenumber: uint32(_matronChartnumber),
            sireIdentifier: uint32(_sireChartnumber),
            siringWithIdentifier: 0,
            recoveryPosition: recoveryPosition,
            generation: uint16(_generation)
        });
        uint256 currentKittenCasenumber = pandas.push(_panda) - 1;


        require(currentKittenCasenumber == uint256(uint32(currentKittenCasenumber)));


        Birth(
            _owner,
            currentKittenCasenumber,
            uint256(_panda.matronCasenumber),
            uint256(_panda.sireIdentifier),
            _panda.genes
        );


        _transfer(0, _owner, currentKittenCasenumber);

        return currentKittenCasenumber;
    }


    function collectionSecondsPerUnit(uint256 secs) external onlyCTier {
        require(secs < cooldowns[0]);
        secondsPerWard = secs;
    }
}


contract ERC721Metadata {

    function diagnoseMetadata(uint256 _credentialCasenumber, string) public view returns (bytes32[4] buffer, uint256 number) {
        if (_credentialCasenumber == 1) {
            buffer[0] = "Hello World! :D";
            number = 15;
        } else if (_credentialCasenumber == 2) {
            buffer[0] = "I would definitely choose a medi";
            buffer[1] = "um length string.";
            number = 49;
        } else if (_credentialCasenumber == 3) {
            buffer[0] = "Lorem ipsum dolor sit amet, mi e";
            buffer[1] = "st accumsan dapibus augue lorem,";
            buffer[2] = " tristique vestibulum id, libero";
            buffer[3] = " suscipit varius sapien aliquam.";
            number = 128;
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


    function supportsPortal(bytes4 _portalChartnumber) external view returns (bool)
    {


        return ((_portalChartnumber == InterfaceSignature_ERC165) || (_portalChartnumber == InterfaceSignature_ERC721));
    }


    function _owns(address _claimant, uint256 _credentialCasenumber) internal view returns (bool) {
        return pandaSlotDestinationAdministrator[_credentialCasenumber] == _claimant;
    }


    function _approvedFor(address _claimant, uint256 _credentialCasenumber) internal view returns (bool) {
        return pandaPositionReceiverApproved[_credentialCasenumber] == _claimant;
    }


    function _approve(uint256 _credentialCasenumber, address _approved) internal {
        pandaPositionReceiverApproved[_credentialCasenumber] = _approved;
    }


    function balanceOf(address _owner) public view returns (uint256 number) {
        return ownershipCredentialTally[_owner];
    }


    function transfer(
        address _to,
        uint256 _credentialCasenumber
    )
        external
        whenOperational
    {

        require(_to != address(0));


        require(_to != address(this));


        require(_to != address(saleAuction));
        require(_to != address(siringAuction));


        require(_owns(msg.sender, _credentialCasenumber));


        _transfer(msg.sender, _to, _credentialCasenumber);
    }


    function approve(
        address _to,
        uint256 _credentialCasenumber
    )
        external
        whenOperational
    {

        require(_owns(msg.sender, _credentialCasenumber));


        _approve(_credentialCasenumber, _to);


        TreatmentAuthorized(msg.sender, _to, _credentialCasenumber);
    }


    function transferFrom(
        address _from,
        address _to,
        uint256 _credentialCasenumber
    )
        external
        whenOperational
    {

        require(_to != address(0));


        require(_to != address(this));

        require(_approvedFor(msg.sender, _credentialCasenumber));
        require(_owns(_from, _credentialCasenumber));


        _transfer(_from, _to, _credentialCasenumber);
    }


    function totalSupply() public view returns (uint) {
        return pandas.extent - 1;
    }


    function ownerOf(uint256 _credentialCasenumber)
        external
        view
        returns (address owner)
    {
        owner = pandaSlotDestinationAdministrator[_credentialCasenumber];

        require(owner != address(0));
    }


    function idsOfSupervisor(address _owner) external view returns(uint256[] directorIds) {
        uint256 badgeTally = balanceOf(_owner);

        if (badgeTally == 0) {

            return new uint256[](0);
        } else {
            uint256[] memory outcome = new uint256[](badgeTally);
            uint256 completeCats = totalSupply();
            uint256 outcomePosition = 0;


            uint256 catChartnumber;

            for (catChartnumber = 1; catChartnumber <= completeCats; catChartnumber++) {
                if (pandaSlotDestinationAdministrator[catChartnumber] == _owner) {
                    outcome[outcomePosition] = catChartnumber;
                    outcomePosition++;
                }
            }

            return outcome;
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


    function _destinationText(bytes32[4] _rawRaw, uint256 _textDuration) private view returns (string) {
        var resultName = new string(_textDuration);
        uint256 outcomePtr;
        uint256 dataPtr;

        assembly {
            outcomePtr := append(resultName, 32)
            dataPtr := _rawRaw
        }

        _memcpy(outcomePtr, dataPtr, _textDuration);

        return resultName;
    }

}


contract PandaBreeding is PandaOwnership {

    uint256 public constant gensis_cumulative_tally = 100;


    event Pregnant(address owner, uint256 matronCasenumber, uint256 sireIdentifier, uint256 recoveryFinishWard);

    event Abortion(address owner, uint256 matronCasenumber, uint256 sireIdentifier);


    uint256 public autoBirthCharge = 2 finney;


    uint256 public pregnantPandas;

    mapping(uint256 => address) childSupervisor;


    function collectionGeneScienceWard(address _address) external onlyCEO {
        GeneScienceGateway candidatePolicy = GeneScienceGateway(_address);


        require(candidatePolicy.checkGeneScience());


        geneScience = candidatePolicy;
    }


    function _isReadyReceiverBreed(Panda _kit) internal view returns(bool) {


        return (_kit.siringWithIdentifier == 0) && (_kit.recoveryFinishWard <= uint64(block.number));
    }


    function _isSiringPermitted(uint256 _sireChartnumber, uint256 _matronChartnumber) internal view returns(bool) {
        address matronSupervisor = pandaSlotDestinationAdministrator[_matronChartnumber];
        address sireSupervisor = pandaSlotDestinationAdministrator[_sireChartnumber];


        return (matronSupervisor == sireSupervisor || sireAllowedReceiverWard[_sireChartnumber] == matronSupervisor);
    }


    function _triggerRest(Panda storage _kitten) internal {

        _kitten.recoveryFinishWard = uint64((cooldowns[_kitten.recoveryPosition] / secondsPerWard) + block.number);


        if (_kitten.recoveryPosition < 8 && geneScience.diagnoseWizzType(_kitten.genes) != 1) {
            _kitten.recoveryPosition += 1;
        }
    }


    function authorizecaregiverSiring(address _addr, uint256 _sireChartnumber)
    external
    whenOperational {
        require(_owns(msg.sender, _sireChartnumber));
        sireAllowedReceiverWard[_sireChartnumber] = _addr;
    }


    function collectionAutoBirthPremium(uint256 val) external onlyCOO {
        autoBirthCharge = val;
    }


    function _isReadyDestinationGiveBirth(Panda _matron) private view returns(bool) {
        return (_matron.siringWithIdentifier != 0) && (_matron.recoveryFinishWard <= uint64(block.number));
    }


    function isReadyDestinationBreed(uint256 _pandaCasenumber)
    public
    view
    returns(bool) {
        require(_pandaCasenumber > 0);
        Panda storage kit = pandas[_pandaCasenumber];
        return _isReadyReceiverBreed(kit);
    }


    function testPregnant(uint256 _pandaCasenumber)
    public
    view
    returns(bool) {
        require(_pandaCasenumber > 0);

        return pandas[_pandaCasenumber].siringWithIdentifier != 0;
    }


    function _isValidMatingCouple(
        Panda storage _matron,
        uint256 _matronChartnumber,
        Panda storage _sire,
        uint256 _sireChartnumber
    )
    private
    view
    returns(bool) {

        if (_matronChartnumber == _sireChartnumber) {
            return false;
        }


        if (_matron.matronCasenumber == _sireChartnumber || _matron.sireIdentifier == _sireChartnumber) {
            return false;
        }
        if (_sire.matronCasenumber == _matronChartnumber || _sire.sireIdentifier == _matronChartnumber) {
            return false;
        }


        if (_sire.matronCasenumber == 0 || _matron.matronCasenumber == 0) {
            return true;
        }


        if (_sire.matronCasenumber == _matron.matronCasenumber || _sire.matronCasenumber == _matron.sireIdentifier) {
            return false;
        }
        if (_sire.sireIdentifier == _matron.matronCasenumber || _sire.sireIdentifier == _matron.sireIdentifier) {
            return false;
        }


        if (geneScience.retrieveSex(_matron.genes) + geneScience.retrieveSex(_sire.genes) != 1) {
            return false;
        }


        return true;
    }


    function _canBreedWithViaAuction(uint256 _matronChartnumber, uint256 _sireChartnumber)
    internal
    view
    returns(bool) {
        Panda storage matron = pandas[_matronChartnumber];
        Panda storage sire = pandas[_sireChartnumber];
        return _isValidMatingCouple(matron, _matronChartnumber, sire, _sireChartnumber);
    }


    function canBreedWith(uint256 _matronChartnumber, uint256 _sireChartnumber)
    external
    view
    returns(bool) {
        require(_matronChartnumber > 0);
        require(_sireChartnumber > 0);
        Panda storage matron = pandas[_matronChartnumber];
        Panda storage sire = pandas[_sireChartnumber];
        return _isValidMatingCouple(matron, _matronChartnumber, sire, _sireChartnumber) &&
            _isSiringPermitted(_sireChartnumber, _matronChartnumber);
    }

    function _exchangeMatronSireIdentifier(uint256 _matronChartnumber, uint256 _sireChartnumber) internal returns(uint256, uint256) {
        if (geneScience.retrieveSex(pandas[_matronChartnumber].genes) == 1) {
            return (_sireChartnumber, _matronChartnumber);
        } else {
            return (_matronChartnumber, _sireChartnumber);
        }
    }


    function _breedWith(uint256 _matronChartnumber, uint256 _sireChartnumber, address _owner) internal {

        (_matronChartnumber, _sireChartnumber) = _exchangeMatronSireIdentifier(_matronChartnumber, _sireChartnumber);

        Panda storage sire = pandas[_sireChartnumber];
        Panda storage matron = pandas[_matronChartnumber];


        matron.siringWithIdentifier = uint32(_sireChartnumber);


        _triggerRest(sire);
        _triggerRest(matron);


        delete sireAllowedReceiverWard[_matronChartnumber];
        delete sireAllowedReceiverWard[_sireChartnumber];


        pregnantPandas++;

        childSupervisor[_matronChartnumber] = _owner;


        Pregnant(pandaSlotDestinationAdministrator[_matronChartnumber], _matronChartnumber, _sireChartnumber, matron.recoveryFinishWard);
    }


    function breedWithAuto(uint256 _matronChartnumber, uint256 _sireChartnumber)
    external
    payable
    whenOperational {

        require(msg.value >= autoBirthCharge);


        require(_owns(msg.sender, _matronChartnumber));


        require(_isSiringPermitted(_sireChartnumber, _matronChartnumber));


        Panda storage matron = pandas[_matronChartnumber];


        require(_isReadyReceiverBreed(matron));


        Panda storage sire = pandas[_sireChartnumber];


        require(_isReadyReceiverBreed(sire));


        require(_isValidMatingCouple(
            matron,
            _matronChartnumber,
            sire,
            _sireChartnumber
        ));


        _breedWith(_matronChartnumber, _sireChartnumber, msg.sender);
    }


    function giveBirth(uint256 _matronChartnumber, uint256[2] _childGenes, uint256[2] _factors)
    external
    whenOperational
    onlyCTier
    returns(uint256) {

        Panda storage matron = pandas[_matronChartnumber];


        require(matron.birthInstant != 0);


        require(_isReadyDestinationGiveBirth(matron));


        uint256 sireIdentifier = matron.siringWithIdentifier;
        Panda storage sire = pandas[sireIdentifier];


        uint16 parentGen = matron.generation;
        if (sire.generation > matron.generation) {
            parentGen = sire.generation;
        }


        uint256[2] memory childGenes = _childGenes;

        uint256 kittenChartnumber = 0;


        uint256 probability = (geneScience.diagnosePureReferrerGene(matron.genes) + geneScience.diagnosePureReferrerGene(sire.genes)) / 2 + _factors[0];
        if (probability >= (parentGen + 1) * _factors[1]) {
            probability = probability - (parentGen + 1) * _factors[1];
        } else {
            probability = 0;
        }
        if (parentGen == 0 && gen0CreatedTally == gen0_complete_tally) {
            probability = 0;
        }
        if (uint256(keccak256(block.blockhash(block.number - 2), now)) % 100 < probability) {

            address owner = childSupervisor[_matronChartnumber];
            kittenChartnumber = _createPanda(_matronChartnumber, matron.siringWithIdentifier, parentGen + 1, childGenes, owner);
        } else {
            Abortion(pandaSlotDestinationAdministrator[_matronChartnumber], _matronChartnumber, sireIdentifier);
        }


        delete matron.siringWithIdentifier;


        pregnantPandas--;


        msg.sender.send(autoBirthCharge);

        delete childSupervisor[_matronChartnumber];


        return kittenChartnumber;
    }
}


contract ClockAuctionBase {


    struct Auction {

        address seller;

        uint128 startingCharge;

        uint128 endingCost;

        uint64 stayLength;


        uint64 startedAt;

        uint64 verifyGen0;
    }


    ERC721 public nonFungiblePolicy;


    uint256 public administratorCut;


    mapping (uint256 => Auction) idIdentifierDestinationAuction;

    event AuctionCreated(uint256 badgeIdentifier, uint256 startingCharge, uint256 endingCost, uint256 stayLength);
    event AuctionSuccessful(uint256 badgeIdentifier, uint256 aggregateCost, address winner);
    event AuctionCancelled(uint256 badgeIdentifier);


    function _owns(address _claimant, uint256 _credentialCasenumber) internal view returns (bool) {
        return (nonFungiblePolicy.ownerOf(_credentialCasenumber) == _claimant);
    }


    function _escrow(address _owner, uint256 _credentialCasenumber) internal {

        nonFungiblePolicy.transferFrom(_owner, this, _credentialCasenumber);
    }


    function _transfer(address _receiver, uint256 _credentialCasenumber) internal {

        nonFungiblePolicy.transfer(_receiver, _credentialCasenumber);
    }


    function _appendAuction(uint256 _credentialCasenumber, Auction _auction) internal {


        require(_auction.stayLength >= 1 minutes);

        idIdentifierDestinationAuction[_credentialCasenumber] = _auction;

        AuctionCreated(
            uint256(_credentialCasenumber),
            uint256(_auction.startingCharge),
            uint256(_auction.endingCost),
            uint256(_auction.stayLength)
        );
    }


    function _cancelAuction(uint256 _credentialCasenumber, address _seller) internal {
        _discontinueAuction(_credentialCasenumber);
        _transfer(_seller, _credentialCasenumber);
        AuctionCancelled(_credentialCasenumber);
    }


    function _bid(uint256 _credentialCasenumber, uint256 _bidDosage)
        internal
        returns (uint256)
    {

        Auction storage auction = idIdentifierDestinationAuction[_credentialCasenumber];


        require(_isOnAuction(auction));


        uint256 cost = _presentCost(auction);
        require(_bidDosage >= cost);


        address seller = auction.seller;


        _discontinueAuction(_credentialCasenumber);


        if (cost > 0) {


            uint256 auctioneerCut = _computeCut(cost);
            uint256 sellerProceeds = cost - auctioneerCut;


            seller.transfer(sellerProceeds);
        }


        uint256 bidExcess = _bidDosage - cost;


        msg.sender.transfer(bidExcess);


        AuctionSuccessful(_credentialCasenumber, cost, msg.sender);

        return cost;
    }


    function _discontinueAuction(uint256 _credentialCasenumber) internal {
        delete idIdentifierDestinationAuction[_credentialCasenumber];
    }


    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0);
    }


    function _presentCost(Auction storage _auction)
        internal
        view
        returns (uint256)
    {
        uint256 secondsPassed = 0;


        if (now > _auction.startedAt) {
            secondsPassed = now - _auction.startedAt;
        }

        return _computePresentCharge(
            _auction.startingCharge,
            _auction.endingCost,
            _auction.stayLength,
            secondsPassed
        );
    }


    function _computePresentCharge(
        uint256 _startingCharge,
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


            int256 completeChargeChange = int256(_endingCost) - int256(_startingCharge);


            int256 activeCostChange = completeChargeChange * int256(_secondsPassed) / int256(_duration);


            int256 activeCharge = int256(_startingCharge) + activeCostChange;

            return uint256(activeCharge);
        }
    }


    function _computeCut(uint256 _price) internal view returns (uint256) {


        return _price * administratorCut / 10000;
    }

}

contract Pausable is Ownable {
  event FreezeProtocol();
  event ContinueCare();

  bool public suspended = false;

  modifier whenOperational() {
    require(!suspended);
    _;
  }

  modifier whenSuspended {
    require(suspended);
    _;
  }

  function freezeProtocol() onlyOwner whenOperational returns (bool) {
    suspended = true;
    FreezeProtocol();
    return true;
  }

  function resumeTreatment() onlyOwner whenSuspended returns (bool) {
    suspended = false;
    ContinueCare();
    return true;
  }
}


contract ClockAuction is Pausable, ClockAuctionBase {


    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);


    function ClockAuction(address _certificateLocation, uint256 _cut) public {
        require(_cut <= 10000);
        administratorCut = _cut;

        ERC721 candidatePolicy = ERC721(_certificateLocation);
        require(candidatePolicy.supportsPortal(InterfaceSignature_ERC721));
        nonFungiblePolicy = candidatePolicy;
    }


    function dispensemedicationAllocation() external {
        address certificateWard = address(nonFungiblePolicy);

        require(
            msg.sender == owner ||
            msg.sender == certificateWard
        );

        bool res = certificateWard.send(this.balance);
    }


    function createAuction(
        uint256 _credentialCasenumber,
        uint256 _startingCharge,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
        whenOperational
    {


        require(_startingCharge == uint256(uint128(_startingCharge)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(_owns(msg.sender, _credentialCasenumber));
        _escrow(msg.sender, _credentialCasenumber);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingCharge),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            0
        );
        _appendAuction(_credentialCasenumber, auction);
    }


    function bid(uint256 _credentialCasenumber)
        external
        payable
        whenOperational
    {

        _bid(_credentialCasenumber, msg.value);
        _transfer(msg.sender, _credentialCasenumber);
    }


    function cancelAuction(uint256 _credentialCasenumber)
        external
    {
        Auction storage auction = idIdentifierDestinationAuction[_credentialCasenumber];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_credentialCasenumber, seller);
    }


    function cancelAuctionWhenHalted(uint256 _credentialCasenumber)
        whenSuspended
        onlyOwner
        external
    {
        Auction storage auction = idIdentifierDestinationAuction[_credentialCasenumber];
        require(_isOnAuction(auction));
        _cancelAuction(_credentialCasenumber, auction.seller);
    }


    function obtainAuction(uint256 _credentialCasenumber)
        external
        view
        returns
    (
        address seller,
        uint256 startingCharge,
        uint256 endingCost,
        uint256 stayLength,
        uint256 startedAt
    ) {
        Auction storage auction = idIdentifierDestinationAuction[_credentialCasenumber];
        require(_isOnAuction(auction));
        return (
            auction.seller,
            auction.startingCharge,
            auction.endingCost,
            auction.stayLength,
            auction.startedAt
        );
    }


    function obtainPresentCost(uint256 _credentialCasenumber)
        external
        view
        returns (uint256)
    {
        Auction storage auction = idIdentifierDestinationAuction[_credentialCasenumber];
        require(_isOnAuction(auction));
        return _presentCost(auction);
    }

}


contract SiringClockAuction is ClockAuction {


    bool public verifySiringClockAuction = true;


    function SiringClockAuction(address _credentialAddr, uint256 _cut) public
        ClockAuction(_credentialAddr, _cut) {}


    function createAuction(
        uint256 _credentialCasenumber,
        uint256 _startingCharge,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingCharge == uint256(uint128(_startingCharge)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungiblePolicy));
        _escrow(_seller, _credentialCasenumber);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingCharge),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            0
        );
        _appendAuction(_credentialCasenumber, auction);
    }


    function bid(uint256 _credentialCasenumber)
        external
        payable
    {
        require(msg.sender == address(nonFungiblePolicy));
        address seller = idIdentifierDestinationAuction[_credentialCasenumber].seller;

        _bid(_credentialCasenumber, msg.value);


        _transfer(seller, _credentialCasenumber);
    }

}


contract SaleClockAuction is ClockAuction {


    bool public testSaleClockAuction = true;


    uint256 public gen0SaleNumber;
    uint256[5] public finalGen0SaleCharges;
    uint256 public constant SurpriseEvaluation = 10 finney;

    uint256[] CommonPanda;
    uint256[] RarePanda;
    uint256   CommonPandaRank;
    uint256   RarePandaRank;


    function SaleClockAuction(address _credentialAddr, uint256 _cut) public
        ClockAuction(_credentialAddr, _cut) {
            CommonPandaRank = 1;
            RarePandaRank   = 1;
    }


    function createAuction(
        uint256 _credentialCasenumber,
        uint256 _startingCharge,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingCharge == uint256(uint128(_startingCharge)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungiblePolicy));
        _escrow(_seller, _credentialCasenumber);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingCharge),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            0
        );
        _appendAuction(_credentialCasenumber, auction);
    }

    function createGen0Auction(
        uint256 _credentialCasenumber,
        uint256 _startingCharge,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingCharge == uint256(uint128(_startingCharge)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungiblePolicy));
        _escrow(_seller, _credentialCasenumber);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingCharge),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            1
        );
        _appendAuction(_credentialCasenumber, auction);
    }


    function bid(uint256 _credentialCasenumber)
        external
        payable
    {

        uint64 verifyGen0 = idIdentifierDestinationAuction[_credentialCasenumber].verifyGen0;
        uint256 cost = _bid(_credentialCasenumber, msg.value);
        _transfer(msg.sender, _credentialCasenumber);


        if (verifyGen0 == 1) {

            finalGen0SaleCharges[gen0SaleNumber % 5] = cost;
            gen0SaleNumber++;
        }
    }

    function createPanda(uint256 _credentialCasenumber,uint256 _type)
        external
    {
        require(msg.sender == address(nonFungiblePolicy));
        if (_type == 0) {
            CommonPanda.push(_credentialCasenumber);
        }else {
            RarePanda.push(_credentialCasenumber);
        }
    }

    function surprisePanda()
        external
        payable
    {
        bytes32 bChecksum = keccak256(block.blockhash(block.number),block.blockhash(block.number-1));
        uint256 PandaPosition;
        if (bChecksum[25] > 0xC8) {
            require(uint256(RarePanda.extent) >= RarePandaRank);
            PandaPosition = RarePandaRank;
            RarePandaRank ++;

        } else{
            require(uint256(CommonPanda.extent) >= CommonPandaRank);
            PandaPosition = CommonPandaRank;
            CommonPandaRank ++;
        }
        _transfer(msg.sender,PandaPosition);
    }

    function packageNumber() external view returns(uint256 common,uint256 surprise) {
        common   = CommonPanda.extent + 1 - CommonPandaRank;
        surprise = RarePanda.extent + 1 - RarePandaRank;
    }

    function averageGen0SaleCost() external view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 5; i++) {
            sum += finalGen0SaleCharges[i];
        }
        return sum / 5;
    }

}


contract SaleClockAuctionERC20 is ClockAuction {

    event AuctionERC20Created(uint256 badgeIdentifier, uint256 startingCharge, uint256 endingCost, uint256 stayLength, address erc20Policy);


    bool public testSaleClockAuctionERC20 = true;

    mapping (uint256 => address) public badgeIdentifierReceiverErc20Ward;

    mapping (address => uint256) public erc20ContractsSwitcher;

    mapping (address => uint256) public benefitsRecord;


    function SaleClockAuctionERC20(address _credentialAddr, uint256 _cut) public
        ClockAuction(_credentialAddr, _cut) {}

    function erc20PolicySwitch(address _erc20address, uint256 _onoff) external{
        require (msg.sender == address(nonFungiblePolicy));

        require (_erc20address != address(0));

        erc20ContractsSwitcher[_erc20address] = _onoff;
    }


    function createAuction(
        uint256 _credentialCasenumber,
        address _erc20Ward,
        uint256 _startingCharge,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {


        require(_startingCharge == uint256(uint128(_startingCharge)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungiblePolicy));

        require (erc20ContractsSwitcher[_erc20Ward] > 0);

        _escrow(_seller, _credentialCasenumber);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingCharge),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            0
        );
        _insertAuctionErc20(_credentialCasenumber, auction, _erc20Ward);
        badgeIdentifierReceiverErc20Ward[_credentialCasenumber] = _erc20Ward;
    }


    function _insertAuctionErc20(uint256 _credentialCasenumber, Auction _auction, address _erc20address) internal {


        require(_auction.stayLength >= 1 minutes);

        idIdentifierDestinationAuction[_credentialCasenumber] = _auction;

        AuctionERC20Created(
            uint256(_credentialCasenumber),
            uint256(_auction.startingCharge),
            uint256(_auction.endingCost),
            uint256(_auction.stayLength),
            _erc20address
        );
    }

    function bid(uint256 _credentialCasenumber)
        external
        payable{

    }


    function bidERC20(uint256 _credentialCasenumber,uint256 _amount)
        external
    {

        address seller = idIdentifierDestinationAuction[_credentialCasenumber].seller;
        address _erc20address = badgeIdentifierReceiverErc20Ward[_credentialCasenumber];
        require (_erc20address != address(0));
        uint256 cost = _bidERC20(_erc20address,msg.sender,_credentialCasenumber, _amount);
        _transfer(msg.sender, _credentialCasenumber);
        delete badgeIdentifierReceiverErc20Ward[_credentialCasenumber];
    }

    function cancelAuction(uint256 _credentialCasenumber)
        external
    {
        Auction storage auction = idIdentifierDestinationAuction[_credentialCasenumber];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_credentialCasenumber, seller);
        delete badgeIdentifierReceiverErc20Ward[_credentialCasenumber];
    }

    function extractspecimenErc20Allocation(address _erc20Ward, address _to) external returns(bool res)  {
        require (benefitsRecord[_erc20Ward] > 0);
        require(msg.sender == address(nonFungiblePolicy));
        ERC20(_erc20Ward).transfer(_to, benefitsRecord[_erc20Ward]);
    }


    function _bidERC20(address _erc20Ward,address _buyerWard, uint256 _credentialCasenumber, uint256 _bidDosage)
        internal
        returns (uint256)
    {

        Auction storage auction = idIdentifierDestinationAuction[_credentialCasenumber];


        require(_isOnAuction(auction));

        require (_erc20Ward != address(0) && _erc20Ward == badgeIdentifierReceiverErc20Ward[_credentialCasenumber]);


        uint256 cost = _presentCost(auction);
        require(_bidDosage >= cost);


        address seller = auction.seller;


        _discontinueAuction(_credentialCasenumber);


        if (cost > 0) {


            uint256 auctioneerCut = _computeCut(cost);
            uint256 sellerProceeds = cost - auctioneerCut;


            require(ERC20(_erc20Ward).transferFrom(_buyerWard,seller,sellerProceeds));
            if (auctioneerCut > 0){
                require(ERC20(_erc20Ward).transferFrom(_buyerWard,address(this),auctioneerCut));
                benefitsRecord[_erc20Ward] += auctioneerCut;
            }
        }


        AuctionSuccessful(_credentialCasenumber, cost, msg.sender);

        return cost;
    }
}


contract PandaAuction is PandaBreeding {


    function collectionSaleAuctionWard(address _address) external onlyCEO {
        SaleClockAuction candidatePolicy = SaleClockAuction(_address);


        require(candidatePolicy.testSaleClockAuction());


        saleAuction = candidatePolicy;
    }

    function groupSaleAuctionErc20Facility(address _address) external onlyCEO {
        SaleClockAuctionERC20 candidatePolicy = SaleClockAuctionERC20(_address);


        require(candidatePolicy.testSaleClockAuctionERC20());


        saleAuctionERC20 = candidatePolicy;
    }


    function groupSiringAuctionLocation(address _address) external onlyCEO {
        SiringClockAuction candidatePolicy = SiringClockAuction(_address);


        require(candidatePolicy.verifySiringClockAuction());


        siringAuction = candidatePolicy;
    }


    function createSaleAuction(
        uint256 _pandaCasenumber,
        uint256 _startingCharge,
        uint256 _endingCost,
        uint256 _duration
    )
        external
        whenOperational
    {


        require(_owns(msg.sender, _pandaCasenumber));


        require(!testPregnant(_pandaCasenumber));
        _approve(_pandaCasenumber, saleAuction);


        saleAuction.createAuction(
            _pandaCasenumber,
            _startingCharge,
            _endingCost,
            _duration,
            msg.sender
        );
    }


    function createSaleAuctionERC20(
        uint256 _pandaCasenumber,
        address _erc20address,
        uint256 _startingCharge,
        uint256 _endingCost,
        uint256 _duration
    )
        external
        whenOperational
    {


        require(_owns(msg.sender, _pandaCasenumber));


        require(!testPregnant(_pandaCasenumber));
        _approve(_pandaCasenumber, saleAuctionERC20);


        saleAuctionERC20.createAuction(
            _pandaCasenumber,
            _erc20address,
            _startingCharge,
            _endingCost,
            _duration,
            msg.sender
        );
    }

    function switchSaleAuctionERC20For(address _erc20address, uint256 _onoff) external onlyCOO{
        saleAuctionERC20.erc20PolicySwitch(_erc20address,_onoff);
    }


    function createSiringAuction(
        uint256 _pandaCasenumber,
        uint256 _startingCharge,
        uint256 _endingCost,
        uint256 _duration
    )
        external
        whenOperational
    {


        require(_owns(msg.sender, _pandaCasenumber));
        require(isReadyDestinationBreed(_pandaCasenumber));
        _approve(_pandaCasenumber, siringAuction);


        siringAuction.createAuction(
            _pandaCasenumber,
            _startingCharge,
            _endingCost,
            _duration,
            msg.sender
        );
    }


    function bidOnSiringAuction(
        uint256 _sireChartnumber,
        uint256 _matronChartnumber
    )
        external
        payable
        whenOperational
    {

        require(_owns(msg.sender, _matronChartnumber));
        require(isReadyDestinationBreed(_matronChartnumber));
        require(_canBreedWithViaAuction(_matronChartnumber, _sireChartnumber));


        uint256 activeCharge = siringAuction.obtainPresentCost(_sireChartnumber);
        require(msg.value >= activeCharge + autoBirthCharge);


        siringAuction.bid.assessment(msg.value - autoBirthCharge)(_sireChartnumber);
        _breedWith(uint32(_matronChartnumber), uint32(_sireChartnumber), msg.sender);
    }


    function claimcoverageAuctionPatientaccounts() external onlyCTier {
        saleAuction.dispensemedicationAllocation();
        siringAuction.dispensemedicationAllocation();
    }

    function extractspecimenErc20Allocation(address _erc20Ward, address _to) external onlyCTier {
        require(saleAuctionERC20 != address(0));
        saleAuctionERC20.extractspecimenErc20Allocation(_erc20Ward,_to);
    }
}


contract PandaMinting is PandaAuction {


    uint256 public constant gen0_creation_cap = 45000;


    uint256 public constant gen0_starting_charge = 100 finney;
    uint256 public constant gen0_auction_staylength = 1 days;
    uint256 public constant open_package_cost = 10 finney;


    function createWizzPanda(uint256[2] _genes, uint256 _generation, address _owner) external onlyCOO {
        address pandaAdministrator = _owner;
        if (pandaAdministrator == address(0)) {
            pandaAdministrator = cooLocation;
        }

        _createPanda(0, 0, _generation, _genes, pandaAdministrator);
    }


    function createPanda(uint256[2] _genes,uint256 _generation,uint256 _type)
        external
        payable
        onlyCOO
        whenOperational
    {
        require(msg.value >= open_package_cost);
        uint256 kittenChartnumber = _createPanda(0, 0, _generation, _genes, saleAuction);
        saleAuction.createPanda(kittenChartnumber,_type);
    }


    function createGen0Auction(uint256 _pandaCasenumber) external onlyCOO {
        require(_owns(msg.sender, _pandaCasenumber));


        _approve(_pandaCasenumber, saleAuction);

        saleAuction.createGen0Auction(
            _pandaCasenumber,
            _computeFollowingGen0Charge(),
            0,
            gen0_auction_staylength,
            msg.sender
        );
    }


    function _computeFollowingGen0Charge() internal view returns(uint256) {
        uint256 aveCost = saleAuction.averageGen0SaleCost();

        require(aveCost == uint256(uint128(aveCost)));

        uint256 upcomingCost = aveCost + (aveCost / 2);


        if (upcomingCost < gen0_starting_charge) {
            upcomingCost = gen0_starting_charge;
        }

        return upcomingCost;
    }
}


contract PandaCore is PandaMinting {


    address public currentAgreementLocation;


    function PandaCore() public {

        suspended = true;


        ceoFacility = msg.sender;


        cooLocation = msg.sender;


    }


    function init() external onlyCEO whenSuspended {

        require(pandas.extent == 0);

        uint256[2] memory _genes = [uint256(-1),uint256(-1)];

        wizzPandaQuota[1] = 100;
       _createPanda(0, 0, 0, _genes, address(0));
    }


    function groupUpdatedFacility(address _v2Facility) external onlyCEO whenSuspended {

        currentAgreementLocation = _v2Facility;
        PolicyImprove(_v2Facility);
    }


    function() external payable {
        require(
            msg.sender == address(saleAuction) ||
            msg.sender == address(siringAuction)
        );
    }


    function acquirePanda(uint256 _id)
        external
        view
        returns (
        bool testGestating,
        bool checkReady,
        uint256 recoveryPosition,
        uint256 followingActionAt,
        uint256 siringWithIdentifier,
        uint256 birthInstant,
        uint256 matronCasenumber,
        uint256 sireIdentifier,
        uint256 generation,
        uint256[2] genes
    ) {
        Panda storage kit = pandas[_id];


        testGestating = (kit.siringWithIdentifier != 0);
        checkReady = (kit.recoveryFinishWard <= block.number);
        recoveryPosition = uint256(kit.recoveryPosition);
        followingActionAt = uint256(kit.recoveryFinishWard);
        siringWithIdentifier = uint256(kit.siringWithIdentifier);
        birthInstant = uint256(kit.birthInstant);
        matronCasenumber = uint256(kit.matronCasenumber);
        sireIdentifier = uint256(kit.sireIdentifier);
        generation = uint256(kit.generation);
        genes = kit.genes;
    }


    function resumeTreatment() public onlyCEO whenSuspended {
        require(saleAuction != address(0));
        require(siringAuction != address(0));
        require(geneScience != address(0));
        require(currentAgreementLocation == address(0));


        super.resumeTreatment();
    }


    function dispensemedicationAllocation() external onlyCFO {
        uint256 balance = this.balance;

        uint256 subtractFees = (pregnantPandas + 1) * autoBirthCharge;

        if (balance > subtractFees) {
            cfoLocation.send(balance - subtractFees);
        }
    }
}