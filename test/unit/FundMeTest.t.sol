// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from '../../src/FundMe.sol';
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

 contract FundMeTest is Test{
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE=0.1 ether; //100000000000000000 
    uint256 constant STARTING_BALANCE=10 ether;
    uint256 constant GAS_PRICE=1;
    function setUp() external{
        // us -> FundMeTest -> FundMe
        //  fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER,STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public{
         assertEq(fundMe.MINIMUM_USD(),5e18);
    }
    function testOwnerIsMsgSender() public{
        console.log(fundMe.getOwner());
        console.log(msg.sender);
         assertEq(fundMe.getOwner (),msg.sender);

    }
    // what can we do to work with addresses outside our system?
    // 1. Unit
    // - Testing a specific part of our code
    //2. Integration
    // - Testing how our code works with other parts of our code
    //3. Forked
    // -Testing our code on a simulated real environment
    //4. Staging
    // - Testing our code in a real environment that is not production
    
    function testPriceFeedVersionIsAccurate() public{
        assertEq(fundMe.getVersion(),4);
    }
    function testFundFailsWithoutEnoughEth() public{
        vm.expectRevert(); //expecting to next line to get reverted
        // assert(this transaction fails because we are not sending enough eth)
        fundMe.fund();
    }
    function testFundUpdatesFundedDataStructure() public{
        vm.prank(USER); // next tx will be sent by USER 
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);
    }
    function testAddsFunderToArrayOfFunders() public{
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder,USER);
    }

    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded{
        // ARRANGE:
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //ACT:
        uint256 gasStart = gasleft(); //1000 gasleft() kisi instant pe batata hai ke kitne gas bachi hai..
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner()); //200
        fundMe.withdraw();

        uint256 gasEnd = gasleft(); //800
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        //ASSERT:
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;  
        assertEq(endingFundMeBalance,0);
        assertEq(startingFundMeBalance + startingOwnerBalance,endingOwnerBalance);  

    }
    function testWithdrawFromMultipleFunders() public funded{
        // ARRANGE:
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i=startingFunderIndex ;i<numberOfFunders;i++){
            //vm.prank()
            //vm.deal()
            // Address
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //ACT:
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //ASSERT:
        assert(address(fundMe).balance == 0);
        assert(fundMe.getOwner().balance == startingOwnerBalance + startingFundMeBalance);  

    }

    function testWithdrawFromMultipleFundersCheaper() public funded{
        // ARRANGE:
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i=startingFunderIndex ;i<numberOfFunders;i++){
            //vm.prank()
            //vm.deal()
            // Address
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //ACT:
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithDraw();
        vm.stopPrank();

        //ASSERT:
        assert(address(fundMe).balance == 0);
        assert(fundMe.getOwner().balance == startingOwnerBalance + startingFundMeBalance);  

    }
 }