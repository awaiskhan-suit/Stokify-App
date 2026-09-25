# 🛒 Stokify — Super Mart Management System

A modern **Super Mart Management System** developed with **Flutter** that provides separate functionality for **Admin** and **Customer** users. The application manages products, categories, customer orders, shopping cart, checkout, order tracking, invoices, expenses, suppliers, and business statistics through a centralized platform.

Stokify is designed to simplify daily super mart operations by connecting customers with the mart while providing administrators with complete control over products, orders, expenses, suppliers, and business activities.

## 🛠️ Technologies Used

* **Flutter** — Cross-platform mobile application development
* **Dart** — Application programming language
* **Firebase Authentication** — Email and password authentication
* **Cloud Firestore** — Managing users, products, categories, orders, suppliers, and expenses
* **Firebase Storage** — Storing product images
* **Provider / State Management** — Managing application state
* **PDF Generation** — Generating invoices and supplier product slips
* **Material Design** — Building a modern and responsive user interface

---

## 👨‍💼 Admin Module

The Admin module provides complete control over the super mart's products, orders, expenses, and suppliers.

### 📦 Product Management

Admin can:

* Add new products
* Enter product name
* Set product price
* Select product category
* Add product image
* Edit product information
* Delete products
* View products by category
* Search products using the search bar

This allows the admin to maintain and organize the complete super mart product catalog.

### 🧾 Order Management

Admin can manage customer orders and update their status, including:

* Accept orders
* Reject orders
* Update order status
* Manage pending orders
* Complete orders
* Mark orders as delivered
* Cancel orders
* Generate invoices from customer orders

Customers can view the updated order status from their accounts.

### 💰 Expense Management

Stokify provides an **Expense Management** module that allows the admin to keep track of the super mart's expenses.

Admin can:

* Add mart expenses
* Record expense details
* View recorded expenses
* Monitor overall expenses
* Review business spending

This helps the admin maintain a clear record of the money spent on different mart activities.

### 🚚 Supplier Management

The Supplier module helps the admin manage product supplies from suppliers.

Admin can:

* Manage supplier information
* Prepare product supply slips
* Select products required from the supplier
* Specify product quantities
* Prepare a supplier product slip
* Generate the supply slip
* Send the product slip to the supplier for product supply

This makes the product ordering process between the super mart and suppliers more organized.

### 📄 Supplier Product Slip

When the mart needs products from a supplier, the admin can prepare a **Product Supply Slip** containing the required product information and quantities.

The generated slip can then be sent to the supplier so the supplier can prepare and supply the requested products.

### 📊 Admin Dashboard

The admin dashboard provides an overview of important super mart activities, including:

* Total Cost
* Today's Cost
* Total Orders
* Today's Orders
* Pending Orders
* Expenses
* Business Statistics

This gives the admin a quick overview of the mart's daily and overall activities.

---

## 👤 Customer Module

Customers can create an account and access the super mart products after authentication.

### 🔐 Authentication

Customers can:

* Sign up using email and password
* Log in using email and password
* Access the home screen after successful login

### 🏠 Home Screen

After login, customers can:

* Browse available products
* Search for products
* Browse products by category
* View product information
* Select products for purchase

### 🛒 Shopping Cart

Customers can add products to their cart and manage their selected items.

The cart allows customers to:

* View selected products
* Increase product quantity
* Decrease product quantity
* Automatically update the corresponding product price
* Review their order before checkout

### 🚚 Checkout & Delivery

When the customer presses the **Checkout** button, a delivery form is displayed.

The customer can enter the required delivery information and submit the order.

After successfully submitting the delivery information, the application displays a **successful order message**.

### 📦 Order Tracking

Customers can track the status of their orders, such as:

* Pending
* Accepted
* Completed
* Delivered
* Cancelled
* Rejected

When the admin changes an order status, the updated status can be viewed by the customer.

### 🧾 Invoice

Admin can generate an invoice based on the customer's order and provide the invoice information to the customer.

---

## ⭐ Key Features

* 👨‍💼 Admin & Customer Modules
* 🔐 Email & Password Authentication
* 📦 Product Management
* 🏷️ Category Management
* 🔍 Product Search
* 🛒 Shopping Cart
* ➕➖ Quantity Management
* 💰 Automatic Price Calculation
* 🚚 Delivery Information
* 📦 Customer Order Management
* 🔄 Order Status Tracking
* 🧾 Invoice Generation
* 💸 Expense Management
* 🚚 Supplier Management
* 📄 Supplier Product Supply Slip
* 📤 Supplier Slip Sharing
* 📊 Admin Dashboard
* 📈 Sales & Order Statistics
* ☁️ Firebase Backend Integration
* 📱 Flutter Cross-Platform Development

---

## 🎯 Project Objective

The main objective of **Stokify** is to provide a complete **digital super mart management and shopping solution** that connects customers with the mart while giving administrators complete control over daily business operations.

The system simplifies product management, customer ordering, cart management, checkout, delivery information, order tracking, invoice generation, expense tracking, supplier management, and product supply requests through a user-friendly mobile application.

## 🚀 Project Highlights

* Complete **Admin and Customer** workflow
* Product and category management
* Customer shopping and ordering
* Dynamic cart and quantity management
* Automated order price calculation
* Order status monitoring
* Invoice generation
* Mart expense tracking
* Supplier management
* Supplier product supply slips
* Easy sharing of product supply requests with suppliers
* Business statistics and dashboard
* Firebase-powered backend
* Modern Flutter-based mobile UI

