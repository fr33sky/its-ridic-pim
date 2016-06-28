# It's Ridic! PIM (Product Information Management)

The It's Ridic! PIM is a Ruby on Rails application mainly designed to integrate data between Amazon MWS and QuickBooks Online.  Additionally, it allows you to keep track of inventory levels, average_cost, and more.

This project roughly works like this:
- You enter your Amazon MWS credentials
- You click a button to integrate the app with QuickBooks Online.  Currently, it will point at a QBO sandbox and not production.
- You enter in the products into the It's Ridic! PIM (name, UPC, price).  You do this by creating a "Product".
- You create an order for these items.  Right now, this is more of a receiving.  Say you purchase something on the internet and private label it.  When you receive the items (or before), you can create an "Order" for these items by entering in the quantity purchased and the amount purchased.  You can add as many line items as you would like.  If this was performed at an earlier time, you can even enter in an optional user-defined date.  This date is used in the calculation of average cost.  If you enter an order before another order, the average cost will be re-calculated based on the dates and quantity available at that time.  This is a weighted average cost.  Once your orders are entered, you can see the total quantity available, average cost, etc.
- You can then retrieve any accounts used by QuickBooks online.  For example, you can click on "Expense Accounts" to see the expense accounts that are in QBO.  This pulls the data from QBO and places it into the application.
- Once the appropriate accounts are in the system, you can click on "Configuration Questions" and answer questions pertaining the creation of data in QBO.  For example, one question is "When creating an expense account, what is the default customer?"  You can then choose the customer from the list that will be used when creating an expense receipt in QBO.
- You click a button to pull new settlement reports from Amazon MWS.  For Amazon Prime, this contains everything you sold in the last 2 weeks.
- You click the "Process" button which will create a sales receipt in the It's Ridic! PIM as well as in QBO.  If an item is found that does not exist in the system, it will automatically create the item.  Inventory levels are automatically deducted.  An expense receipt is also created which tracks expenses from Amazon (e.g. commission per item).  A Journal Entry is being worked on now as well to balance everything out (for use in the cheapest version of QBO).

Since this is in the very early stages of creation, you take full responsibility for using the program at all.

If you're interested in working as a beta tester, let me know!
