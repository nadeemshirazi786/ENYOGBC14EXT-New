table 14228816 "Order Sheet Details"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF6580SHR
    //   20091201 - Modified function jfcbOrderRuleItemCheck(), to set Sell-To Customer No. as it is used in
    //              the call to function lcduOrderRules.jfdoFromOrderSheet
    // 
    // JF12700AC
    //   20110509 - add fields
    //     23019000 "Unit Price"
    //     23019001 "Comment"

    DrillDownPageID = "Order Sheet Details";
    LookupPageID = "Order Sheet Details";
    Permissions = TableData "Order Sheet Details" = imd;

    fields
    {
        field(1; "Entry No."; Integer)
        {
        }
        field(2; "Order Sheet Batch Name"; Code[10])
        {
            TableRelation = "Order Sheet Batch";
        }
        field(5; "Sell-to Customer No."; Code[20])
        {
            TableRelation = Customer;
        }
        field(6; "Ship-to Code"; Code[10])
        {
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Sell-to Customer No."));
        }
        field(7; "Requested Ship Date"; Date)
        {
        }
        field(10; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(11; "Variant Code"; Code[10])
        {
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(12; "Unit of Measure Code"; Code[10])
        {
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(13; Quantity; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(15; "External Doc. No."; Code[20])
        {
        }
        field(20; "Sales Order No."; Code[20])
        {
            TableRelation = "Sales Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(21; "Shipping Agent Code"; Code[10])
        {
            TableRelation = "Shipping Agent";
        }
        field(23019000; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            Description = 'JF12700AC';
        }
        field(23019001; Comment; Text[80])
        {
            Caption = 'Comment';
            Description = 'JF12700AC';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Order Sheet Batch Name", "Sell-to Customer No.", "Ship-to Code", "Item No.", "Variant Code", "Unit of Measure Code", "Requested Ship Date", "Sales Order No.", "External Doc. No.")
        {
            SumIndexFields = Quantity;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        jfcbOrderRuleItemCheck;
    end;

    [Scope('Internal')]
    procedure jfcbOrderRuleItemCheck()
    var
        lcduOrderRules: Codeunit "EN Order Rule Functions";
        lrecSalesLine: Record "Sales Line";
        lrecItem: Record Item;
    begin
        //<AX00025CB>
        lrecSalesLine."Document Type" := lrecSalesLine."Document Type"::Order;
        lrecSalesLine."Document No." := 'ORDER_SHEET';

        lrecSalesLine.Type := lrecSalesLine.Type::Item;
        lrecSalesLine."No." := "Item No.";

        //<JF6580SHR>
        lrecSalesLine."Sell-to Customer No." := "Sell-to Customer No.";
        //</JF6580SHR>

        //<JF13933MG>
        lrecItem.GET("Item No.");

        lrecSalesLine."Item Category Code" := lrecItem."Item Category Code";

        lrecSalesLine."Unit of Measure Code" := "Unit of Measure Code";
        //</JF13933MG>

        lcduOrderRules.doFromOrderSheet("Sell-to Customer No.", "Ship-to Code", "Requested Ship Date");
        lcduOrderRules.cbSalesLineItemOK(lrecSalesLine);
        //</AX00025CB>
    end;

    [Scope('Internal')]
    procedure jfcbOrderRuleQtyDefault()
    var
        lcduOrderRules: Codeunit "EN Order Rule Functions";
        ldecMin: Decimal;
    begin
        //<AX00025CB>
        /*
        ldecMin := lcduOrderRules.jfcbSalesLineDefaultMinQty(Rec);
        IF ldecMin <> 0 THEN BEGIN
          VALIDATE(Quantity,ldecMin);
        END;
        */
        //</AX00025CB>

    end;

    [Scope('Internal')]
    procedure jfcbOrderRuleRoundOrderMult()
    var
        lcduOrderRules: Codeunit "EN Order Rule Functions";
        ldecMin: Decimal;
    begin
        //<AX00025CB>
        /*
        Quantity := lcduOrderRules.jfcbSalesLineOrderMultiple(Rec);
        */
        //</AX00025CB>

    end;
}

