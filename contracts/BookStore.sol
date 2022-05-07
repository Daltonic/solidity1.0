// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract BookStore {
    // Contains global store data
    uint256 taxFee;
    address immutable taxAccount;
    uint8 totalSupply = 0;

    // Specifies book information
    struct BookStruct {
        uint8 id;
        address seller;
        string title;
        string description;
        string author;
        uint256 cost;
        uint256 timestamp;
    }

    // Associates books with sellers and buyers
    BookStruct[] books;
    mapping(address => BookStruct[]) booksOf;
    mapping(uint8 => address) public sellerOf;
    mapping(uint8 => bool) bookExists;

    // Logs out sales record
    event Sale(
        uint8 id,
        address indexed buyer,
        address indexed seller,
        uint256 cost,
        uint256 timestamp
    );
    
    // Logs out created book record
    event Created(
        uint8 id,
        address indexed seller,
        uint256 timestamp
    );

    // Initializes tax on book sale
    constructor(uint256 _taxFee) {
        taxAccount = msg.sender;
        taxFee = _taxFee;
    }

    // Performs book creation
    function createBook(
        string memory title, 
        string memory description, 
        string memory author, 
        uint256 cost
    ) public returns (bool) {
        require(bytes(title).length > 0, "Title empty");
        require(bytes(description).length > 0, "Description empty");
        require(bytes(author).length > 0, "Description empty");
        require(cost > 0 ether, "Price cannot be zero");

        // Adds book to shop
        books.push(
            BookStruct(
                totalSupply++,
                msg.sender,
                title,
                description,
                author,
                cost,
                block.timestamp
            )
        );

        // Records book selling detail
        sellerOf[totalSupply] = msg.sender;
        bookExists[totalSupply] = true;

        emit Created(
            totalSupply,
            msg.sender,
            block.timestamp
        );

        return true;
    }

    // Performs book payment
    function payForBook(uint8 id)
        public payable returns (bool) {
        require(bookExists[id], "Book does not exist");
        require(msg.value >= books[id - 1].cost, "Ethers too small");

        // Computes payment data
        address seller = sellerOf[id];
        uint256 tax = (msg.value / 100) * taxFee;
        uint256 payment = msg.value - tax;

        // Bills buyer on book sale
        payTo(seller, payment);
        payTo(taxAccount, tax);

        // Gives book to buyer
        booksOf[msg.sender].push(books[id - 1]);

        emit Sale(
            id,
            msg.sender,
            seller,
            payment,
            block.timestamp
        );
        
        return true;
    }
    
    // Method 1: The transfer function
    function transferTo(
        address to,
        uint256 amount
    ) internal returns (bool) {
        payable(to).transfer(amount);
        return true;
    }
    
    // Method 2: The send function
    function sendTo(
        address to, 
        uint256 amount
    ) internal returns (bool) {
        require(payable(to).send(amount), "Payment failed");
        return true;
    }

    // Method 3: The call function
    function payTo(
        address to, 
        uint256 amount
    ) internal returns (bool) {
        (bool success,) = payable(to).call{value: amount}("");
        require(success, "Payment failed");
        return true;
    }

    // Returns books of buyer
    function myBooks(address buyer)
        external view returns (BookStruct[] memory) {
        return booksOf[buyer];
    }
    
    // Returns books in store
    function getBooks()
        external view returns (BookStruct[] memory) {
        return books;
    }
    
    // Returns a specific book by id
    function getBook(uint8 id)
        external view returns (BookStruct memory) {
        return books[id - 1];
    }
}