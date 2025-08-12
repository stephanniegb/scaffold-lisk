// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

abstract contract BaseFlowCore is Ownable2Step, ReentrancyGuard {
    IERC20 public immutable usdc;

    struct Invoice {
        address merchant;
        address customer;
        uint256 amount;
        uint256 dueDate;
        bool paid;
        string metadata; // IPFS hash containing invoice details
    }

    struct Inventory {
        string itemId;
        uint256 quantity;
        uint256 price;
        address merchant;
    }

    mapping(bytes32 => Invoice) public invoices;
    mapping(address => mapping(string => Inventory)) public inventory;

    event InvoiceCreated(bytes32 indexed invoiceId, address merchant, address customer, uint256 amount);
    event InvoicePaid(bytes32 indexed invoiceId, address customer, uint256 amount);
    event InventoryUpdated(address merchant, string itemId, uint256 quantity, uint256 price);

    constructor(address _usdc) {
        usdc = IERC20(_usdc);
        _transferOwnership(msg.sender);
    }

    function createInvoice(
        address customer,
        uint256 amount,
        uint256 dueDate,
        string calldata metadata
    ) external returns (bytes32) {
        require(amount > 0, "Invalid amount");
        require(dueDate > block.timestamp, "Invalid due date");

        bytes32 invoiceId = keccak256(
            abi.encodePacked(msg.sender, customer, amount, dueDate, block.timestamp)
        );

        invoices[invoiceId] = Invoice({
            merchant: msg.sender,
            customer: customer,
            amount: amount,
            dueDate: dueDate,
            paid: false,
            metadata: metadata
        });

        emit InvoiceCreated(invoiceId, msg.sender, customer, amount);
        return invoiceId;
    }

    function payInvoice(bytes32 invoiceId) external nonReentrant {
        Invoice storage invoice = invoices[invoiceId];
        require(!invoice.paid, "Invoice already paid");
        require(block.timestamp <= invoice.dueDate, "Invoice expired");
        require(msg.sender == invoice.customer, "Not invoice customer");

        invoice.paid = true;

        require(
            usdc.transferFrom(msg.sender, invoice.merchant, invoice.amount),
            "Payment failed"
        );

        emit InvoicePaid(invoiceId, msg.sender, invoice.amount);
    }

    function updateInventory(
        string calldata itemId,
        uint256 quantity,
        uint256 price
    ) external {
        inventory[msg.sender][itemId] = Inventory({
            itemId: itemId,
            quantity: quantity,
            price: price,
            merchant: msg.sender
        });

        emit InventoryUpdated(msg.sender, itemId, quantity, price);
    }

    function getInventory(address merchant, string calldata itemId)
        external
        view
        returns (Inventory memory)
    {
        return inventory[merchant][itemId];
    }
}