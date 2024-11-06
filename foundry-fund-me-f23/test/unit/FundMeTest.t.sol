// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/ DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user"); //made a user
    uint256 constant SEND_VALUE = 0.1 ether; //100000000000000000
    uint256 constant STARTING_BALANCE = 10 ether; //gave user some money, otherwise it can't perform any task (not an official cheat code)
    uint256 constant Gas_Price = 1;

    function setUp() external {
        // fundMe -> FundMeTest -> FundMe
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); //made a deal
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); //the next line should revert
        //assert (this txn fails)
        fundMe.fund(); //send 0 value, so fails(here, success)
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //next tx will be sent by user
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER); //funder = USER(what this test is checking)
    }
     modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);      //Here, Pretend to be a USER, for "fundMe.withdraw();"
        vm.expectRevert();   //coz, this is a vm
        fundMe.withdraw();
    }
    function testWithdrawWithASingleFunder() public {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act     
        vm.prank(fundMe.getOwner());  
        fundMe.withdraw;

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance, endingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawFromMultipleFunders() public funded{
        //Arrange
        uint160 numberOfFunders = 10;  //to use no to generate addresses, no have to be uint160
        uint160 startingFunderIndex = 1;  //coz sanity checks

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            //vm.prank new address
            //vm.deal  new address
            //address()

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();   }
    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingFundMeBalance = address(fundMe).balance;

//Act
vm.startPrank(fundMe.getOwner());
fundMe.withdraw();
vm.stopPrank();

//Assert
assert(address(fundMe).balance == 0);
assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance); 
    }

 function testWithdrawFromMultipleFundersCheaper() public funded{
        //Arrange
        uint160 numberOfFunders = 10;  //to use no to generate addresses, no have to be uint160
        uint160 startingFunderIndex = 1;  //coz sanity checks

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            //vm.prank new address
            //vm.deal  new address
            //address()

            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();   }
    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingFundMeBalance = address(fundMe).balance;

//Act
vm.startPrank(fundMe.getOwner());
fundMe.cheaperWithdraw();
vm.stopPrank();

//Assert
assert(address(fundMe).balance == 0);
assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance); 
    }
}