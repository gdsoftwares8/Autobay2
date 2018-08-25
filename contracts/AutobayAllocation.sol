pragma solidity 0.4.24;



import "./Ownable.sol";

import "./Autobay.sol";

import "./SafeMath.sol";

import "./ICO.sol";


contract AutobayAllocation is Ownable {



    using SafeMath for uint256;



    uint256 public constant DECIMALS = 18;


    uint256 public constant MONTH_SECONDS = 2629744;

    
    Allocation[] public allocations;


    TeamsAllocation[] public team;

   // uint256 public minted;
    
   // uint256 public periods;

   // uint256 public allocatedPeriods;

    uint256  public  cliff;

    uint256 public cliffAmount;

    Autobay public autobay;
    


    ICO public ico;



    struct Allocation {

        address holderAddress;

        uint256 amount;

        bool sent;

    }

    struct TeamsAllocation {

      
        uint256 allocationTime;

        uint256 period;

        uint startTime;

        uint256 Amount;

        address holderAddress;



    }

  
    constructor(

        address _autobay,

        address _ico

    ) public {

        require(_autobay != address(0) && _ico != address(0));

        autobay = Autobay(_autobay);

        ico = ICO(_ico);

    }



    function setAutobay(address _autobay) public onlyOwner {

        require(_autobay != address(0));

        autobay = Autobay(_autobay);

    }



    function setICO(address _ico) public onlyOwner {

        require(_ico != address(0));

        ico = ICO(_ico);

    }



    function claim() public {

        allocateInternal(msg.sender, now);

    }



    function allocate() public onlyOwner {

        allocateInternal(address(0), now);

    }



    function setAllocation() public onlyOwner {

        allocations.push(Allocation(

        0x61612C3Dd28624265929a8deF4CbA580680FCa3E,

        uint256(141750000).mul(uint(10) ** uint(DECIMALS)),

        false

        ));


     uint256 startTime = ico.startTime();

        team.push(TeamsAllocation(

        12,

        3,

        uint(567000005525).mul(uint(10) ** uint(DECIMALS - 4)),

        startTime,

        0x61612C3Dd28624265929a8deF4CbA580680FCa3E

        ));

        team.push(TeamsAllocation(

        18,

        3,

        uint(850500004475).mul(uint(10) ** uint(DECIMALS - 4)),

        startTime,

        0x61612C3Dd28624265929a8deF4CbA580680FCa3E

        ));

    
    }



    function allocateInternal(address _holder, uint256 _currentTime) internal {



        for (uint256 i = 0; i < allocations.length; i++) {

            if (_holder != address(0) && allocations[i].holderAddress != _holder) {

                continue;

            }

            if (true == allocations[i].sent) {

                continue;

            }

            Allocation storage allocation = allocations[i];

            allocation.sent = true;



            require(allocation.amount == autobay.mint(allocation.holderAddress, allocation.amount));

        }



        for (uint256 j = 0; j < team.length; j++) {

            TeamsAllocation storage member = team[j];

            if (_holder != address(0) && member.holderAddress != _holder) {

                continue;

            }



            uint256 periods = _currentTime.sub(member.allocationTime).div(cliff.mul(MONTH_SECONDS));

            if (periods < 1) {

                continue;

            }



            uint256 allocatedPeriods = member.allocationTime.sub(ico.startTime()).div(cliff.mul(MONTH_SECONDS));

            if (periods.add(allocatedPeriods) > member.period.div(cliff)) {

                periods = member.period.div(cliff).sub(allocatedPeriods);

            }



            uint256 minted = autobay.mint(member.holderAddress, cliffAmount.mul(periods));



            require(minted == cliffAmount.mul(periods));

            member.allocationTime = member.allocationTime.add(cliff.mul(MONTH_SECONDS).mul(periods));

        }

    }



}
