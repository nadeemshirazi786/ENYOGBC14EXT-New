table 23019262 "WO Item Consumption"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF8566SHR
    //   20100520 - Add fields:
    //              30 Purchase Order No.
    //              31 Purchase Receipt No.
    //              32 Purchase Receipt Line No.
    //              33 Applies-to Entry No.
    //            - Added new function jfSelectItemEntry
    // 
    // JF10366SHR
    //   20101102 - Added new field:
    //              26 Description 2
    //            - Changed field 20 Description to normal field. COde to populate both field 20 and 26

    DrillDownPageID = 23019262;
    LookupPageID = 23019262;

    fields
    {
        field(1; "PM Work Order No."; Code[20])
        {
            TableRelation = Table23019260.Field1;
        }
        field(2; "PM Proc. Version No."; Code[10])
        {
            TableRelation = "PM Procedure Header"."Version No." WHERE (Code = FIELD ("PM Procedure Code"));
        }
        field(3; "PM WO Line No."; Integer)
        {
        }
        field(4; "Line No."; Integer)
        {
        }
        field(5; "PM Procedure Code"; Code[20])
        {
            TableRelation = "PM Procedure Header".Code;
        }
        field(10; "Item No."; Code[20])
        {
            TableRelation = Item;

            trigger OnValidate()
            begin
                CalcFields("Location Code");

                if grecItem.Get("Item No.") then begin
                    gjfGetLocation("Location Code");

                    Validate("Unit of Measure", grecItem."Base Unit of Measure");
                    "Inventory Posting Group" := grecItem."Inventory Posting Group";
                    "Gen. Prod. Posting Group" := grecItem."Gen. Prod. Posting Group";
                    //<JF10366SHR>
                    Description := grecItem.Description;
                    "Description 2" := grecItem."Description 2";
                    //</JF10366SHR>

                    if grecLocation."Bin Mandatory" and not grecLocation."Directed Put-away and Pick" then
                        gcduWMSManagement.GetDefaultBin("Item No.", "Variant Code", "Location Code", "Bin Code");

                end else begin
                    "Unit of Measure" := '';
                    "Inventory Posting Group" := '';
                    "Gen. Prod. Posting Group" := '';
                    "Qty. per Unit of Measure" := 0;
                    "Bin Code" := '';
                    //<JF10366SHR>
                    Description := '';
                    "Description 2" := '';
                    //</JF10366SHR>

                end;
            end;
        }
        field(11; "Unit of Measure"; Code[10])
        {
            TableRelation = "Item Unit of Measure".Code WHERE ("Item No." = FIELD ("Item No."));

            trigger OnValidate()
            begin
                if grecItemUOM.Get("Item No.", "Unit of Measure") then begin
                    "Qty. per Unit of Measure" := grecItemUOM."Qty. per Unit of Measure";
                end;
            end;
        }
        field(12; "Quantity Installed"; Decimal)
        {
            Caption = 'Quantity Installed';
            DecimalPlaces = 0 : 5;
        }
        field(13; "Qty. per Unit of Measure"; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(15; "Planned Usage Qty."; Decimal)
        {
            Caption = 'Planned Usage Qty.';
            DecimalPlaces = 0 : 5;
        }
        field(16; "Qty. to Consume"; Decimal)
        {
            Caption = 'Qty. to Consume';
            DecimalPlaces = 0 : 5;
        }
        field(20; Description; Text[50])
        {
            FieldClass = Normal;
        }
        field(21; "Inventory Posting Group"; Code[10])
        {
            TableRelation = "Inventory Posting Group";
        }
        field(22; "Gen. Prod. Posting Group"; Code[10])
        {
            TableRelation = "Gen. Product Posting Group";
        }
        field(23; "Bin Code"; Code[20])
        {
            TableRelation = "Bin Content"."Bin Code" WHERE ("Item No." = FIELD ("Item No."),
                                                            "Variant Code" = FIELD ("Variant Code"),
                                                            "Location Code" = FIELD ("Location Code"));
        }
        field(24; "Location Code"; Code[10])
        {
            CalcFormula = Lookup (Table23019260.Field106 WHERE (Field1 = FIELD ("PM Work Order No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(25; "Variant Code"; Code[10])
        {
            TableRelation = "Item Variant".Code WHERE ("Item No." = FIELD ("Item No."));
        }
        field(26; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            Description = 'JF10366SHR';
        }
        field(30; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            Description = 'JF8566SHR';
        }
        field(31; "Purchase Receipt No."; Code[20])
        {
            Caption = 'Purchase Receipt No.';
            Description = 'JF8566SHR';
        }
        field(32; "Purchase Receipt Line No."; Integer)
        {
            Caption = 'Purchase Receipt Line No.';
            Description = 'JF8566SHR';
        }
        field(33; "Applies-to Entry"; Integer)
        {
            Caption = 'Applies-to Entry';
            Description = 'JF8566SHR';

            trigger OnLookup()
            begin
                //<JF8566SHR>
                jfSelectItemEntry(FieldNo("Applies-to Entry"));
                //</JF8566SHR>
            end;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
            begin
                //<JF8566SHR>
                if "Applies-to Entry" <> 0 then begin
                    ItemLedgEntry.Get("Applies-to Entry");
                    ItemLedgEntry.TestField(Positive, true);
                end else begin
                    "Purchase Order No." := '';
                    "Purchase Receipt No." := '';
                    "Purchase Receipt Line No." := 0;
                end;
                //</JF8566SHR>
            end;
        }
    }

    keys
    {
        key(Key1; "PM Work Order No.", "PM WO Line No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if HasLinks then
            DeleteLinks;
    end;

    var
        grecItem: Record Item;
        grecItemUOM: Record "Item Unit of Measure";
        grecLocation: Record Location;
        gcduWMSManagement: Codeunit "WMS Management";

    local procedure gjfGetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Clear(grecLocation)
        else
            if grecLocation.Code <> LocationCode then
                grecLocation.Get(LocationCode);
    end;

    local procedure jfSelectItemEntry(CurrentFieldNo: Integer)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemJnlLine2: Record "Item Journal Line";
    begin
        //<JF8566SHR>
        ItemLedgEntry.SetCurrentKey("Item No.", Positive);
        ItemLedgEntry.SetRange("Item No.", "Item No.");
        ItemLedgEntry.SetRange(Correction, false);
        CalcFields("Location Code");
        if "Location Code" <> '' then
            ItemLedgEntry.SetRange("Location Code", "Location Code");

        ItemLedgEntry.SetRange(Open, true);
        ItemLedgEntry.SetRange(Positive, true);

        if PAGE.RunModal(PAGE::"Item Ledger Entries", ItemLedgEntry) = ACTION::LookupOK then begin
            Validate("Applies-to Entry", ItemLedgEntry."Entry No.");
        end;
        //</JF8566SHR>
    end;
}

