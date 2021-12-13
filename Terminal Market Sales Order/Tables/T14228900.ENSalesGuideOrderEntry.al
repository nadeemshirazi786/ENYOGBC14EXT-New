table 14228900 "EN Sales Guide Order Entry"
{
    Caption = 'Sales Guide Order Entry';

    fields
    {
        field(1; "Order No."; Code[20])
        {
            Caption = 'Order No.';
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin

            end;
        }
        field(3; Description; Text[30])
        {
            Caption = 'Description';
        }
        field(4; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(5; "Item Variant Code"; Code[10])
        {
            Caption = 'Item Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(6; "Last Order Date"; Date)
        {
            Caption = 'Last Order Date';
        }
        field(7; "Last Order Unit Price"; Decimal)
        {
            Caption = 'Last Order Unit Price';
        }
        field(8; "Last Order Quantity Shipped"; Decimal)
        {
            Caption = 'Last Order Quantity Shipped';
        }
        field(9; "Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(10; "Item Category"; Code[10])
        {
            Caption = 'Item Category';
        }
        field(11; "Product Group"; Code[10])
        {
            Caption = 'Product Group';
        }
        field(12; Inventory; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry"."Remaining Quantity" WHERE("Item No." = FIELD("Item No."),
                                                                              "Variant Code" = FIELD("Item Variant Code"),
                                                                              Open = CONST(true),
                                                                              "Country/Reg of Origin Code ELA" = FIELD("Country/Region of Origin Code")));
            Caption = 'Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Qty. on Purch. Order"; Decimal)
        {
            CalcFormula = Sum("Purchase Line"."Outstanding Qty. (Base)" WHERE("No." = FIELD("Item No."),
                                                                               "Variant Code" = FIELD("Item Variant Code"),
                                                                               "Country/Reg of Origin Code ELA" = FIELD("Country/Region of Origin Code"),
                                                                               "Drop Shipment" = CONST(false),
                                                                               "Expected Receipt Date" = FIELD("Date Filter"),
                                                                               "Document Type" = CONST(Order),
                                                                               Type = CONST(Item),
                                                                               "Outstanding Quantity" = FILTER(> 0)));
            Caption = 'Qty. on Purch. Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Qty. on Sales Order"; Decimal)
        {
            CalcFormula = Sum("Sales Line"."Outstanding Qty. (Base)" WHERE("Document Type" = CONST(Order),
                                                                            Type = CONST(Item),
                                                                            "No." = FIELD("Item No."),
                                                                            "Variant Code" = FIELD("Item Variant Code"),
                                                                            "Drop Shipment" = CONST(false),
                                                                            "Country/Reg of Origin Code ELA" = FIELD("Country/Region of Origin Code")));
            Caption = 'Qty. on Sales Order';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(16; "Sales Unit of Measure"; Code[10])
        {
            Caption = 'Sales Unit of Measure';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(20; "Description 2"; Text[30])
        {
            Caption = 'Description 2';
        }
        field(30; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';

            trigger OnValidate()
            begin

                if (xRec."Unit Price" <> "Unit Price") and (xRec."Unit Price" <> 0) and
                   (CurrFieldNo = 30) then begin
                    if ("Unit Price" > (1.15 * xRec."Unit Price")) then begin
                        if not Confirm(Text50000, false, FieldCaption("Unit Price")) then begin
                            "Unit Price" := xRec."Unit Price";
                        end;
                    end else
                        if ("Unit Price" < (0.85 * xRec."Unit Price")) then begin
                            if not Confirm(Text50001, false, FieldCaption("Unit Price")) then begin
                                "Unit Price" := xRec."Unit Price";
                            end;
                        end;
                end;

            end;
        }
        field(40; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(100; "Qty. On Hand"; Decimal)
        {
            DecimalPlaces = 0 : 5;
            Description = '84732';
        }
        field(200; "User ID"; Code[50])
        {
            Description = '84732';
        }
        field(201; "Form Start"; DateTime)
        {
            Description = '84732';
        }
        field(50000; Clearance; Boolean)
        {
        }
        field(14228900; "Supply Chain Group Code"; Code[10])
        {
            Caption = 'Supply Chain Group Code';
            Description = 'Sales Team,DA0066,ENTMS1.00';
            TableRelation = "EN Supply Chain Group";
        }
        field(14228901; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            Description = 'ENTMS1.00';
            TableRelation = "Country/Region";

            trigger OnValidate()
            var
                Item: Record Item;
                ItemTracking: Record "Item Tracking Code";
                ResEntry: Record "Reservation Entry";
                LotInfo: Record "Lot No. Information";
            begin
            end;
        }
    }

    keys
    {
        key(Key1; "Order No.", "Item No.", "Item Variant Code", "Supply Chain Group Code")
        {
            Clustered = true;
        }
        key(Key2; "User ID", "Form Start")
        {
        }
    }

    fieldgroups
    {
    }

    var
        SearchItemLedgEntry: Record "Item Ledger Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line" temporary;
        Item: Record Item;
        PriceCalcMgt: Codeunit "Sales Price Calc. Mgt.";
        Text37002005: Label 'Only contract items are allowed.';
        Text50000: Label 'Price entered is greater than 15% above Market Price.  Do you want to continue?';
        Text50001: Label 'Price entered is less than 15% below Market Price,  Do you want to continue?';

    procedure xFindLastValues()
    begin
        SearchItemLedgEntry.SetCurrentKey("Item No.", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
        SearchItemLedgEntry.SetRange("Item No.", "Item No.");
        SearchItemLedgEntry.SetRange("Entry Type", SearchItemLedgEntry."Entry Type"::Sale);
        if SearchItemLedgEntry.Find('+') then begin

            "Last Order Date" := (SearchItemLedgEntry."Posting Date");

            "Last Order Quantity Shipped" := -SearchItemLedgEntry.Quantity;
            if "Last Order Quantity Shipped" = 0 then
                "Last Order Unit Price" := 0
            else begin
                SearchItemLedgEntry.CalcFields("Sales Amount (Actual)");
                if SearchItemLedgEntry."Sales Amount (Actual)" <> 0 then
                    "Last Order Unit Price" := SearchItemLedgEntry."Sales Amount (Actual)" / "Last Order Quantity Shipped"
                else
                    "Last Order Unit Price" := SearchItemLedgEntry."Sales Amount (Expected)" / "Last Order Quantity Shipped";
            end;
        end;
    end;

    procedure UpdateUnitPrice(CalledByFieldNo: Integer)
    var
        Text0001: Label 'Sales Line Unit Price %1';
    begin
        if (CalledByFieldNo <> CurrFieldNo) and (CurrFieldNo <> 0) then
            exit;

        SalesHeader.Get(SalesHeader."Document Type"::Order, "Order No.");

        SalesLine."Document Type" := SalesLine."Document Type"::Order;
        SalesLine."Document No." := "Order No.";
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine.Validate("No.", "Item No.");
        SalesLine.Validate("Variant Code", "Item Variant Code");
        SalesLine.Quantity := Quantity;
        SalesLine."Unit of Measure Code" := "Sales Unit of Measure";
        if not SalesLine.Insert then
            SalesLine.Modify;
        if SalesLine.Type = SalesLine.Type::Item then begin
            PriceCalcMgt.FindSalesLinePrice(SalesHeader, SalesLine, CalledByFieldNo);
            /*IF SalesHeader."Contract Items Only" AND
              (NOT PriceCalcMgt.IsContractItem)
            THEN
              ERROR(Text37002005);*///TBR
            PriceCalcMgt.FindSalesLineLineDisc(SalesHeader, SalesLine);
        end;
        Validate("Unit Price", SalesLine."Unit Price");
        Modify;

    end;
}

