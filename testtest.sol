// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract Library{
    constructor(){
        libAdmin=msg.sender;
    }

    uint amountBooks = 0;
    address libAdmin;

    struct Book {
        string name;
        string picture;
        bool availability;
    }

    mapping (uint => Book) bookNumber;

    //------------Admin

    function changeAdmin(address _newAdmin) public {
        require(libAdmin==msg.sender, "Only admin");
        libAdmin = _newAdmin;
    }

    //------------Book

    function createBook(string calldata _name, string calldata _image) public returns(uint){
        require(libAdmin==msg.sender, "Only admin");
        //book creation
        bookNumber[amountBooks] = Book(_name, _image, true);
        amountBooks++;
    }

    function bookInfo(uint _bookID) public view returns ( Book memory){
        return bookNumber[_bookID];
    }

    mapping(uint => address) rentedTo;
    uint public priceForMonthRent = 1000000 gwei;

    function rentBook(uint _bookId, uint _month) public payable{
        require(_bookId<amountBooks, "Not exist");
        require(msg.value==priceForMonthRent*_month, "Not enogh funds");
        //require(rentedTo[_bookId]==0x0000000000000000000000000000000000000000, "Already rented");
        require(bookNumber[_bookId].availability, "Already rented");
        rentedTo[_bookId] = msg.sender;
        bookNumber[_bookId].availability = false;
    }
    
    function whereIsBook(uint _bookID) public view returns(address){
        require(_bookID<amountBooks, "Not Exist");
        return rentedTo[_bookID];
    }

    function returnBook(uint _bookID) public{
        require(msg.sender==libAdmin || msg.sender ==rentedTo[_bookID], "only admin");
        bookNumber[_bookID].availability = true;
        delete rentedTo[_bookID];
    }

    function withdraw() public { 
        require(libAdmin==msg.sender, "Only admin"); 
        payable(libAdmin).transfer(address(this).balance); 
    }



}
