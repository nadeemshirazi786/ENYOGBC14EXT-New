enum 51000 SHeaderOrderStatus
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Activated)
    {
        Caption = 'Activated';
    }
    value(2; "Require Call")
    {
        Caption = 'Require Call';
    }
    value(3; Confirmed)
    {
        Caption = 'Confirmed';
    }
    value(4; Cancelled)
    {
        Caption = 'Cancelled';
    }
    value(5; Delivery)
    {
        Caption = 'Delivery';
    }
    value(6; Special)
    {
        Caption = 'Special';
    }
}
enum 51001 PstedPalletSrc
{
    Extensible = true;

    value(0; "Std. Pallet")
    {
        Caption = 'Std. Pallet';
    }
    value(1; "Whse. Shipment Pallet")
    {
        Caption = 'Whse. Shipment Pallet';
    }
}
enum 51002 StandingOrderStatus
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Activated)
    {
        Caption = 'Activated';
    }
    value(2; Confirmed)
    {
        Caption = 'Confirmed';
    }
    value(3; Delivery)
    {
        Caption = 'Delivery';
    }
}
enum 51003 DistributionType
{
    Extensible = true;

    value(0; Equal)
    {
        Caption = 'Equal';
    }
    value(1; Amount)
    {
        Caption = 'Amount';
    }
    value(2; Weight)
    {
        Caption = 'Weight';
    }
    value(3; Pallet)
    {
        Caption = 'Pallet';
    }
    value(4; Quantity)
    {
        Caption = 'Quantity';
    }
}
enum 51004 ItemVendStatus
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Pending)
    {
        Caption = 'Pending';
    }
    value(2; Approved)
    {
        Caption = 'Approved';
    }
}
enum 51005 Weekdays
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Monday")
    {
        Caption = 'Monday';
    }
    value(2; "Tuesday")
    {
        Caption = 'Tuesday';
    }
    value(3; "Wednesday")
    {
        Caption = 'Wednesday';
    }
    value(4; "Thursday")
    {
        Caption = 'Thursday';
    }
    value(5; "Friday")
    {
        Caption = 'Friday';
    }
    value(6; "Saturday")
    {
        Caption = 'Saturday';
    }
    value(7; "Sunday")
    {
        Caption = 'Sunday';
    }
}
enum 51006 BPostSHeader
{
    Extensible = true;

    value(0; "Credit Memo and Sales Order")
    {
        Caption = 'Credit Memo and Sales Order';
    }
    value(1; "Credit Memo")
    {
        Caption = 'Credit Memo';
    }
    value(2; " ")
    {
        Caption = ' ';
    }
    value(3; None)
    {
        Caption = 'None';
    }
}
enum 51007 SortOrderLine
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Item Category-Product Group")
    {
        Caption = 'Item Category-Product Group';
    }
}
enum 51008 BlockedItemsOnActivate
{
    Extensible = true;

    value(0; Error)
    {
        Caption = 'Error';
    }
    value(1; Skip)
    {
        Caption = 'Skip';
    }
}
enum 51009 ReclassJnlDate
{
    Extensible = true;

    value(0; "Shipment Date")
    {
        Caption = 'Shipment Date';
    }
    value(1; WorkDate)
    {
        Caption = 'WorkDate';
    }
}
enum 51010 CustomRecExt
{
    Extensible = true;

    value(0; "0")
    {
        Caption = '0';
    }
    value(1; "1")
    {
        Caption = '1';
    }
    value(2; "2")
    {
        Caption = '2';
    }
    value(3; "3")
    {
        Caption = '3';
    }
    value(4; "4")
    {
        Caption = '4';
    }
    value(5; "5")
    {
        Caption = '5';
    }
    value(6; "6")
    {
        Caption = '6';
    }
    value(7; "7")
    {
        Caption = '7';
    }
    value(8; "8")
    {
        Caption = '8';
    }
    value(9; "9")
    {
        Caption = '9';
    }
    value(10; "10")
    {
        Caption = '10';
    }
}
enum 51011 ApplToDocType
{
    Extensible = true;

    value(0; Quote)
    {
        Caption = 'Quote';
    }
    value(1; Order)
    {
        Caption = 'Order';
    }
    value(2; Invoice)
    {
        Caption = 'Invoice';
    }
    value(3; "Credit Memo")
    {
        Caption = 'Credit Memo';
    }
    value(4; "Blanket Order")
    {
        Caption = 'Blanket Order';
    }
    value(5; "Return Order")
    {
        Caption = 'Return Order';
    }
    value(6; Reciept)
    {
        Caption = 'Reciept';
    }
    value(7; "Transfer Reciept")
    {
        Caption = 'Transfer Reciept';
    }
    value(8; "Return Shipment")
    {
        Caption = 'Return Shipment';
    }
    value(9; "Sales Shipment")
    {
        Caption = 'Sales Shipment';
    }
    value(10; "Return Reciept")
    {
        Caption = 'Return Reciept';
    }
    value(11; "Sales Order")
    {
        Caption = 'Sales Order';
    }
}
enum 51012 CostType
{
    Extensible = true;

    value(0; Document)
    {
        Caption = 'Document';
    }
    value(1; Line)
    {
        Caption = 'Line';
    }
}
enum 51013 ApplToFunctionalArea
{
    Extensible = true;

    value(0; Sales)
    {
        Caption = 'Sales';
    }
    value(1; Purchase)
    {
        Caption = 'Purchase';
    }
    value(2; Transfer)
    {
        Caption = 'Transfer';
    }
}
enum 51014 DocType
{
    Extensible = true;

    value(0; "Purchase Invoice")
    {
        Caption = 'Purchase Invoice';
    }
    value(1; "Purchase Order")
    {
        Caption = 'Purchase Order';
    }
}
enum 51015 JFFieldClass
{
    Extensible = true;

    value(0; "Normal")
    {
        Caption = 'Normal';
    }
    value(1; "FlowFilter")
    {
        Caption = 'FlowFilter';
    }
    value(2; "Flowfield")
    {
        Caption = 'FlowField';
    }
}
enum 51016 SetWanted
{
    Extensible = true;
    
    value(0; "Initial")
    {
        Caption = 'Initial';
    }
    value(1; "Previous")
    {
        Caption = 'Previous';
    }
    value(2; "Same")
    {
        Caption = 'Same';
    }
    value(3; "Next")
    {
        Caption = 'Next';
    }
    value(4; "PreviousColumn")
    {
        Caption = 'PreviousColumn';
    }
    value(5; "NextColumn")
    {
        Caption = 'NextColumn';
    }
}
